#### bridge driver on user defined network

* Users can create their own networks called user-defined networks of any network driver type. 
* Docker will create a new Linux bridge on the host. 
* User-defined networks supports manual IP address and subnet assignment. 
* If an assignment isn't given, then Docker's default IPAM driver will assign the next subnet available in the private IP space.

~~~
# Create a user-defined bridge network for our application 
host $ docker network create -d bridge net1 
       0b94b69e065efe462168c16a4c946bc60507cb51edf9dd730cc9aa5a5112c062
~~~
By default bridge will be assigned one subnet from the ranges 172.[17-31].0.0/16 or 192.168.[0-240].0/20   
which does not overlap with any existing host interface ( why is that an issue ? )

~~~
host $ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "brctl show"
                 bridge name	bridge id		STP enabled	interfaces
                 docker0		8000.0242730c554e	no		veth0b4775f
                 br-70cff723f8f7		8000.02429b7d1515	no
                 
~~~
We can see the 2nd bridge interface

~~~
routing table
host $ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "ip route"
       default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
       172.17.0.0/16 dev docker0  src 172.17.0.1
       172.18.0.0/16 dev br-70cff723f8f7  src 172.18.0.1
       192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204

~~~
We get another rule for the new bridge

~~~
changes in iptables filter table
host $ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "iptables -L -v"
       Chain INPUT (policy ACCEPT 2 packets, 152 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain FORWARD (policy DROP 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
           0     0 DOCKER     all  --  any    br-70cff723f8f7  anywhere             anywhere
           0     0 ACCEPT     all  --  any    br-70cff723f8f7  anywhere             anywhere             ctstate RELATED,ESTABLISHED
           0     0 ACCEPT     all  --  br-70cff723f8f7 !br-70cff723f8f7  anywhere             anywhere
           0     0 ACCEPT     all  --  br-70cff723f8f7 br-70cff723f8f7  anywhere             anywhere
           0     0 DOCKER     all  --  any    docker0  anywhere             anywhere
           0     0 ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
           0     0 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
           0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere
       
       Chain OUTPUT (policy ACCEPT 2 packets, 152 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain DOCKER (2 references)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain DOCKER-ISOLATION (1 references)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DROP       all  --  docker0 br-70cff723f8f7  anywhere             anywhere
           0     0 DROP       all  --  br-70cff723f8f7 docker0  anywhere             anywhere
           0     0 RETURN     all  --  any    any     anywhere             anywhere
~~~

Communication between different Docker networks is firewalled by default.
This is a fundamental security aspect that allows us to provide network policy using Docker networks.

~~~
host $ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "iptables -L -v -t nat"
       Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL
       
       Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain OUTPUT (policy ACCEPT 2 packets, 152 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER     all  --  any    any     anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
       
       Chain POSTROUTING (policy ACCEPT 2 packets, 152 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 MASQUERADE  all  --  any    !br-70cff723f8f7  172.18.0.0/16        anywhere
           0     0 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
       
       Chain DOCKER (2 references)
        pkts bytes target     prot opt in     out     source               destination
           0     0 RETURN     all  --  br-70cff723f8f7 any     anywhere             anywhere
           0     0 RETURN     all  --  docker0 any     anywhere             anywhere
~~~

let's create 2 containers, a server and a client. 
~~~

host $ docker run -d --rm --name server --net net1 -p 8000 busybox busybox httpd -f -p 8000
host $ docker run  -t --rm --net net1 --name client odedpriva/docker-networking ping -c1 server
       PING server (172.18.0.2): 56 data bytes
       64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.114 ms
       
       --- server ping statistics ---
       1 packets transmitted, 1 packets received, 0% packet loss
       round-trip min/avg/max = 0.114/0.114/0.114 ms
~~~
As of Docker 1.10, the docker daemon implements an embedded DNS server which provides built-in service discovery for any container created with a valid name or net-alias or aliased by link. 
~~~
host $ docker run -d --rm --net net1 --name client odedpriva/docker-networking arping  server
       ARPING to 172.18.0.2 from 172.18.0.3 via eth0
       Unicast reply from 172.18.0.2 [02:42:AC:12:00:02] 0.027ms
       Sent 1 probe(s) (1 broadcast(s))
       Received 1 replies (0 request(s), 0 broadcast(s))
~~~
brctl now shows a second Linux bridge on the host. 
The name of the Linux bridge, br-70cff723f8f7, matches the Network ID of the net1 network. 
net1 also has two veth interfaces connected to containers server and client.
~~~
host $ docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "brctl show"
       bridge name	bridge id		STP enabled	interfaces
       docker0		8000.0242730c554e	no		veth57904b2
       br-70cff723f8f7		8000.02429b7d1515	no		veth55aa84f
       							                        vethcfc0c8e
       							
host $ docker network inspect net1 -f '{{.ID}}'
       70cff723f8f736e3c5c439801afeccf70a64d2935c17ad1461869598f478fd8d
       
host $ docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "ip link | grep UP"
       1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
       4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
       15: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
       22: br-70cff723f8f7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
       44: veth55aa84f@if43: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue master br-70cff723f8f7 state UP
       68: vethcfc0c8e@if67: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue master br-70cff723f8f7 state UP
       82: veth5a3f17e@if81: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue master docker0 state UP
~~~

* By default all containers on the same bridge driver network will have connectivity with each other without extra configuration.
This is an aspect of most types of Docker networks
* Communication between different Docker networks is firewalled by default
 
 
#### links
* https://github.com/docker/labs/blob/master/networking/concepts/05-bridge-networks.md
* https://docs.docker.com/engine/userguide/networking/configure-dns/