overlay driver
====

Let's start by creating a swarm using docker-in-docker
~~~
10-docker-overlay-networking $ chmod +x docker-swarm.sh && ./docker-swarm.sh -w -s
~~~

This is what we created in high level
![overlay network 1](https://docs.google.com/drawings/d/1n3TX41f3SiQSe_qW5tGng-rJPv1ZMFqDmTehz0uKwFY/pub?w=960&h=540)


let's run our exposed ( exposed on our manager ) port with a request
~~~
host$ for i in {1..5}; do curl localhost:8000/etc/hostname; echo ; done
{"serverHostName":"a1ad988af922","proxyHostName":"64b044c48309"}
{"serverHostName":"c72f9c46389d","proxyHostName":"a051c9e81e7b"}
{"serverHostName":"c72f9c46389d","proxyHostName":"64b044c48309"}
{"serverHostName":"a1ad988af922","proxyHostName":"a051c9e81e7b"}
{"serverHostName":"a1ad988af922","proxyHostName":"64b044c48309"}
~~~

let's follow our reques to try and understad how this magic happens

1. First let's investigate the ingress load balancing and the routing mesh
It is a new feature in Docker 1.12 that combines ipvs and iptables to create a powerful cluster-wide transport-layer (L4) load balancer
When any Swarm node receives traffic destined to the published TCP/UDP port of a running service, it forwards it to service's VIP using a pre-defined overlay network called ingress

In high level, this is how it goes: 

![overlay network 2](https://docs.google.com/drawings/d/1VcU77UHCVwQH_537bsspuW5DwMZqAWKg8w-Ue8wqrs0/pub?w=960&h=540)

1. The request hit our manager on eth0. 
2. The request goes through the iptables NAT table to DOCKER-INGRESS chain and is forwarded to 172.19.0.2 .
~~~
host$ manager iptables -t nat -L PREROUTING 1
      DOCKER-INGRESS  all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL
host$ manager iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
~~~
3. The request goes through the `docker_gwbridge` into the `ingress-sbox`
4. In the `ingress-sbox`, docker uses mangle mark rule to mark packets with ipvs fwmark id.
In general, The MARK target lets us set a 32-bit value (or 0xFFFFFFFF) on a packet, which we can then look for later with the mark match 
This is basically the external load-balancing part as the destination will be RR through all our proxy containers.
~~~
host$ manager nsenter --net=/var/run/docker/netns/ingress_sbox iptables -t mangle -L PREROUTING 1
      **MARK**     tcp  --  anywhere             anywhere             tcp dpt:8000 MARK set 0x103
host$ manager nsenter --net=/var/run/docker/netns/ingress_sbox iptables -t nat -L POSTROUTING 2
      SNAT       all  --  anywhere             10.255.0.0/16        ipvs to:10.255.0.3
host$ manager nsenter --net=/var/run/docker/netns/ingress_sbox ipvsadm -L
      IP Virtual Server version 1.2.1 (size=4096)
      Prot LocalAddress:Port Scheduler Flags
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
      FWM  259 rr
      -> 10.255.0.8:0                 Masq    1      0          0
      -> 10.255.0.9:0                 Masq    1      0          0
~~~

Now, our packet needs to find his way to the vxlan tunnel, 
This is done using the net ingress-network that has a bridge interface connecting containers network with the vxlan tunnel.
~~~
host$ manager nsenter --net=/var/run/docker/netns/1-b0tba1uoso brctl show br0
      bridge name	bridge id		STP enabled	interfaces
      br0		8000.5e81d7221f6d	no		vxlan1
							      veth2
~~~


ingress ? what is ingress ? 

![ingress](img/ingress.png)


the iptables rules
---
~~~
host$ manager iptables -t nat -L PREROUTING 1
      DOCKER-INGRESS  all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL
      host$ manager iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
      host$ proxy iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
      host$ server iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000

~~~




the routing table
---

~~~
host$ manager ip -o route
      default via 172.18.0.1 dev eth0
      172.17.0.0/16 dev docker0  src 172.17.0.1
      172.18.0.0/16 dev eth0  src 172.18.0.2
      172.19.0.0/16 dev docker_gwbridge  src 172.19.0.1
~~~

~~~
host$ manager docker network ls

NETWORK ID          NAME                DRIVER              SCOPE
fb9152b494ec        bridge              bridge              local
21ce4a33a60d        docker_gwbridge     bridge              local
7e6a5df179a3        host                host                local
c60vezcxgz45        ingress             overlay             swarm
541df91ecff5        none                null                local
~~~

this is what we got: 


let's `ping` server container from proxy container
~~~
host$ proxy docker exec 23356667f1ad4529e ping 10.0.0.4
      PING 10.0.0.4 (10.0.0.4): 56 data bytes
      64 bytes from 10.0.0.4: seq=0 ttl=64 time=0.562 ms
      64 bytes from 10.0.0.4: seq=1 ttl=64 time=0.265 ms
~~~


let's  `traceroute` server container from proxy container
~~~
host$ proxy docker exec 23356667f1ad4529e traceroute 10.0.0.4
      traceroute to 10.0.0.4 (10.0.0.4), 30 hops max, 46 byte packets
      1  server.2.cagptma3ag0c8e6qy1s3n0umj.mynet (10.0.0.4)  0.013 ms  0.015 ms  0.099 ms
~~~

let's check the server service
 
~~~
 

now, let's see how this magic happens

First let's investigate the ingress load balancing and the routing mesh
It is a new feature in Docker 1.12 that combines ipvs and iptables to create a powerful cluster-wide transport-layer (L4) load balancer
When any Swarm node receives traffic destined to the published TCP/UDP port of a running service, it forwards it to service's VIP using a pre-defined overlay network called ingress

In high level, this is how it goes: 

![routing-mesh-ingress](img/routing-mesh-ingress.png)

the interfaces
~~~
host$ manager ip -o -f inet a
      1: lo    inet 127.0.0.1/8 scope host lo\       valid_lft forever preferred_lft forever
      10: docker0    inet 172.17.0.1/16 scope global docker0\       valid_lft forever preferred_lft forever
      15: docker_gwbridge    inet 172.19.0.1/16 scope global docker_gwbridge\       valid_lft forever preferred_lft forever
      45: eth0    inet 172.18.0.2/16 scope global eth0\       valid_lft forever preferred_lft forever
~~~

ingress ? what is ingress ? 

![ingress](img/ingress.png)


the iptables rules
---
~~~
host$ manager iptables -t nat -L PREROUTING 1
      DOCKER-INGRESS  all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL
      host$ manager iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
      host$ proxy iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
      host$ server iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000

~~~

the routing table
---
~~~
host$ manager ip -o route
      default via 172.18.0.1 dev eth0
      172.17.0.0/16 dev docker0  src 172.17.0.1
      172.18.0.0/16 dev eth0  src 172.18.0.2
      172.19.0.0/16 dev docker_gwbridge  src 172.19.0.1
~~~


|   | Namespace            | docker network  | interface       | address    |
|:-:|----------------------|-----------------|-----------------|------------|
| 1 | docker-for-mac       | nethandson      | br-             | 172.18.0.1 |
| 2 | manager              | mynet           | eth0            | 172.18.0.2 |
| 3 | manager              | mynet           | docker_gwbridge | 172.19.0.1 |
| 4 | manager ingress-sbox | mynet           | eth1            | 172.19.0.2 |
| 5 | manager ingress-sbox | mynet           | eth0            | 10.255.0.2 |
 
you can monitor traffic using the following : 

| namespace            | interface       | tcpdump command                                                                                                                                      |
|----------------------|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| manager              | eth0            | `manager tcpdump ip and port 8000 and '(((ip[2:2] - ((ip[0]&0xf)>2)) != 0)' -i eth0 --immediate-mode                                                `|
| manager              | docker_gwbridge | `manager tcpdump ip and port 8000 and '(((ip[2:2] - ((ip[0]&0xf)>2)) != 0)' -i docker_gwbridge --immediate-mode                                       `|
| manager ingress_sbox | eth1            | `manager nsenter --net=/var/run/docker/netns/ingress_sbox tcpdump ip and port 8000 and '(((ip[2:2] - ((ip[0]&0xf)>2)) != 0)' -i eth1 --immediate-mode `|
| manager ingress_sbox | eth0            | `manager nsenter --net=/var/run/docker/netns/ingress_sbox tcpdump ip and port 8000 and '(((ip[2:2] - ((ip[0]&0xf)>2)) != 0)' -i eth0 --immediate-mode `|



external load-balancing
---
1. The request hit our manager on eth0. 
2. The request goes to the iptables NAT rule.
~~~
host$ manager iptables -t nat -L PREROUTING 1
      DOCKER-INGRESS  all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL
host$ manager iptables -t nat -L DOCKER-INGRESS 1
      DNAT       tcp  --  anywhere             anywhere             tcp dpt:8000 to:172.19.0.2:8000
~~~
3. The request goes through the `docker_gwbridge` into the `ingress-sbox`
4. In the `ingress-sbox`, docker uses mangle mark rule to mark packets with ipvs fwmark id.
In general, The MARK target lets us set a 32-bit value (or 0xFFFFFFFF) on a packet, which we can then look for later with the mark match 
This is basically the external load-balancing part as the destination will be RR through all our proxy containers.
~~~
host$ manager nsenter --net=/var/run/docker/netns/ingress_sbox iptables -t mangle -L PREROUTING 1
      **MARK**     tcp  --  anywhere             anywhere             tcp dpt:8000 MARK set 0x103
host$ manager nsenter --net=/var/run/docker/netns/ingress_sbox ipvsadm -L
      IP Virtual Server version 1.2.1 (size=4096)
      Prot LocalAddress:Port Scheduler Flags
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
      FWM  259 rr
      -> 10.255.0.8:0                 Masq    1      0          0
      -> 10.255.0.9:0                 Masq    1      0          0
~~~

~~~
host$ manager docker service inspect --format '{{.Spec.Name}}-{{json .Endpoint.VirtualIPs}}' $(manager docker service ls -q)
      server-[{"NetworkID":"ddxnkhz3tzaq2ce7sul7qofyk","Addr":"10.0.0.2/24"}]
      proxy-[{"NetworkID":"20408srk3176a0yeyjxdxkh28","Addr":"10.255.0.6/16"},{"NetworkID":"ddxnkhz3tzaq2ce7sul7qofyk","Addr":"10.0.0.5/24"}]
~~~

VXLAN
---

![vxlan](img/demistifying-vxkan.png)


internal service descovery
---
Now that our request found its way to one of the proxy containers, it needs to continue to server service. 
![internal dns service](img/dns-service.png)
1. docker uses internal dns listenning to requests on 127.0.0.11
~~~
host$ proxy docker inspect --format '{{.NetworkSettings.SandboxKey}}' $(proxy docker ps -q)
      /var/run/docker/netns/71b8347d85b1
      /var/run/docker/netns/eb8acedbf23c
host$ proxy nsenter --net=/var/run/docker/netns/71b8347d85b1 tcpdump -i any -n --immediate-mode
.. 
~~~


The service is given a Virtual IP address that is routable only inside the Docker Network. 
When requests are made to the IP address, they are distributed to the underlying containers. 
This Virtual IP is registered with the Embedded DNS server in Docker. 
When a DNS lookup is made based on the service name, the Virtual IP is returned.
DNS server is embedded inside Docker engine. Docker DNS resolves the service name and returns list of container ip addresses in random order. 
Clients normally will pick the first IP so that load balancing can happen between the different instance of the servers.

let's see this in action by monitoring networking on all nodes and containers .. 

the server node
~~~
host$ server docker run --rm --net=container:$(server docker ps  -l -q) crccheck/tcpdump not port 7946 and not port 2377 -i any --immediate-mode
# not port - filter out swarm communication among nodes (7946) and cluster management communications (2377)
# -i any - all interfaces
# --immediate-mode - don't buffer output. 
~~~




service discovery 

load balancing

ingress load balancing

The mynet (overlay) network - The ingress and egress point to the overlay network that VXLAN encapsulates and (optionally) encrypts traffic going between containers on the same overlay network


#### links
* http://www.slideshare.net/Docker/docker-networking-deep-dive  
* http://www.slideshare.net/Docker/docker-networking-control-plane-and-data-plane  
* [Docker Networking: Control Plane and Data Plane](https://www.youtube.com/watch?v=2EfOJhtjhIk)  
* [Docker Meetup #42](https://www.youtube.com/watch?v=2ihqKMDRkxM)  
* http://securitynik.blogspot.co.il/2016/12/docker-networking-internals-container.html  
* [tcpdump usage](http://www.tcpdump.org/tcpdump_man.html)
* http://stackoverflow.com/questions/38812357/whats-the-purpose-of-binding-vip-addr-in-every-container-of-a-service-in-docker
* http://blog.nigelpoulton.com/demystifying-docker-overlay-networking/

 is the routing mash network, it is the only network created on all nodes.
* dns service is running inside the daemon. 
* the net1 network will be created on demand.
* docker_gwbridge is used as a gateway to the outer world

TCP port 2377 for cluster management communications.
TCP and UDP port 7946 for communication among nodes.
TCP and UDP port 4789 for overlay network traffic, (vxlan uses udp port 4789):



#### overlay driver
* An overlay network is a computer network that is built on top of another network. 
Nodes in the overlay network can be thought of as being connected by virtual or logical links, each of which corresponds to a path, perhaps through many physical links, in the underlying network

![overlay network](img/overlay-simple.jpg)

* With the overlay driver, multi-host networks are first-class citizens inside Docker without external provisioning or components

* The `overlay` driver utilizes an industry-standard VXLAN data plane that decouples the container network from the underlying physical network (the underlay)
* VXLAN, encapsulates L2 into UDP. Tunneling using L3 means that no specialized hardware is required and such overlay networks could be build purely in software.

![overlay network](img/vxlan-dataflow-1.jpg)
![overlay network](img/vxlan-dataflow-2.jpg)


and when it comes to docker
* Docker overlay networks are used in the context of docker clusters (Docker Swarm), where a virtual network used by containers needs to span multiple physical hosts running the docker engine  
Swarm scopes overlay networks cannot be used for "docker run", only for services
![overlay network](img/packet-walk.png)