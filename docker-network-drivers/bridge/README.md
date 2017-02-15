bridge driver on user defined network
===

As we have seen, bridge networks are LOCAL scope networking. 

* Users can create their own networks called user-defined networks of any network driver type. 
* Docker will create a new `Linux bridge` on the host. 
* User-defined networks supports manual IP address and subnet assignment. 
* If an assignment isn't given, then Docker's default `IPAM` driver will assign the next subnet available in the private IP space.

Create a user-defined bridge network for our application 
~~~
docker network create -d bridge net1 
       0b94b69e065efe462168c16a4c946bc60507cb51edf9dd730cc9aa5a5112c062
~~~
By default bridge will be assigned one subnet from the ranges 172.[17-31].0.0/16 or 192.168.[0-240].0/20   
which does not overlap with any existing host interface ( why is that an issue ? )

check using `docker network inspect net1` the net1 configuration.

let's check what was changed in our docker engine host.

#### interfaces
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "brctl show"
                 bridge name	bridge id		STP enabled	interfaces
                 docker0		8000.0242730c554e	no		veth0b4775f
                 br-70cff723f8f7		8000.02429b7d1515	no              
~~~

#### routing
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "ip route"
       default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
       172.17.0.0/16 dev docker0  src 172.17.0.1
       172.18.0.0/16 dev br-70cff723f8f7  src 172.18.0.1
       192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204

~~~

#### iptables - filter
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -L -v"
    Chain INPUT (policy ACCEPT 5 packets, 380 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain FORWARD (policy DROP 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
        0     0 DOCKER     all  --  any    br-529897d6d9f3  anywhere             anywhere
        0     0 ACCEPT     all  --  any    br-529897d6d9f3  anywhere             anywhere             ctstate RELATED,ESTABLISHED
        0     0 ACCEPT     all  --  br-529897d6d9f3 !br-529897d6d9f3  anywhere             anywhere
        0     0 ACCEPT     all  --  br-529897d6d9f3 br-529897d6d9f3  anywhere             anywhere
        0     0 DOCKER     all  --  any    docker0  anywhere             anywhere
        0     0 ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
        0     0 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
        0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere

    Chain OUTPUT (policy ACCEPT 10 packets, 2195 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain DOCKER (2 references)
    pkts bytes target     prot opt in     out     source               destination

    Chain DOCKER-ISOLATION (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DROP       all  --  docker0 br-529897d6d9f3  anywhere             anywhere
        0     0 DROP       all  --  br-529897d6d9f3 docker0  anywhere             anywhere
        0     0 RETURN     all  --  any    any     anywhere             anywhere
~~~

Communication between different Docker networks is firewalled by default.
This is a fundamental security aspect that allows us to provide network policy using Docker networks.

#### iptables - nat
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -t nat -L -v -n "
    Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

    Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain OUTPUT (policy ACCEPT 10 packets, 2195 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

    Chain POSTROUTING (policy ACCEPT 10 packets, 2195 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 MASQUERADE  all  --  *      !br-529897d6d9f3  172.18.0.0/16        0.0.0.0/0
        0     0 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0

    Chain DOCKER (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 RETURN     all  --  br-529897d6d9f3 *       0.0.0.0/0            0.0.0.0/0
        0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
~~~


**let's create 2 containers, a server and a client.**
~~~

docker run -d --rm --name server --net net1 -p 8000 busybox busybox httpd -f -p 8000
docker run -d --rm --name proxy --net net1 -p 8000:8000 proxy
curl localhost:8000/etc/hostname
    {"serverHostName":"9999d7406a60","proxyHostName":"03c214ee095b"}
~~~

![bridge - 1](https://docs.google.com/drawings/d/110n48AVqH4P_zhM5SCiy82gIR0el0Vp2EGpgw9eGzaQ/pub?w=960&h=540)


As of Docker 1.10, the docker daemon implements an embedded DNS server which provides built-in service discovery for any container created with a valid name or net-alias or aliased by link. 
~~~
docker exec proxy ping -c1 server
    PING server (172.18.0.2): 56 data bytes
    64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.162 ms

    --- server ping statistics ---
    1 packets transmitted, 1 packets received, 0% packet loss
    round-trip min/avg/max = 0.162/0.162/0.162 ms
~~~

The name of the Linux bridge, br-84ec5b4d9561, matches the Network ID of the net1 network. 
net1 also has two veth interfaces connected to containers server and proxy.
~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "brctl show "
    bridge name	bridge id		STP enabled	interfaces
    docker0		8000.0242fb86a5da	no		veth882f7db
    br-84ec5b4d9561		8000.0242703a4560	no		veth716b06e
                                                    veth3df3684
       							
docker network inspect net1 -f '{{.ID}}'
    84ec5b4d9561e81fbae3cd2e7c8e07a3da876a82c5d22cde3a91d910cdab9cc5
~~~

let's inspect net1 network by using `docker network inspect net1` .. what do we see? 

let's check iptables
#### iptables - filter
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -t filter -L -v"
    Chain INPUT (policy ACCEPT 34 packets, 2995 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain FORWARD (policy DROP 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
    1450  122K DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
    1450  122K DOCKER     all  --  any    br-84ec5b4d9561  anywhere             anywhere
    1445  121K ACCEPT     all  --  any    br-84ec5b4d9561  anywhere             anywhere             ctstate RELATED,ESTABLISHED
        0     0 ACCEPT     all  --  br-84ec5b4d9561 !br-84ec5b4d9561  anywhere             anywhere
        5   348 ACCEPT     all  --  br-84ec5b4d9561 br-84ec5b4d9561  anywhere             anywhere
        0     0 DOCKER     all  --  any    docker0  anywhere             anywhere
        0     0 ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
        0     0 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
        0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere

    Chain OUTPUT (policy ACCEPT 40 packets, 2812 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain DOCKER (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 ACCEPT     tcp  --  !br-84ec5b4d9561 br-84ec5b4d9561  anywhere             172.18.0.2           tcp dpt:8000
        0     0 ACCEPT     tcp  --  !br-84ec5b4d9561 br-84ec5b4d9561  anywhere             172.18.0.3           tcp dpt:8000

    Chain DOCKER-ISOLATION (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DROP       all  --  docker0 br-84ec5b4d9561  anywhere             anywhere
        0     0 DROP       all  --  br-84ec5b4d9561 docker0  anywhere             anywhere
    1450  122K RETURN     all  --  any    any     anywhere             anywhere
~~~


#### iptables - nat
~~~
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -t nat -L -v"
    Chain PREROUTING (policy ACCEPT 5 packets, 348 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL

    Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain OUTPUT (policy ACCEPT 15 packets, 1078 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DOCKER     all  --  any    any     anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

    Chain POSTROUTING (policy ACCEPT 20 packets, 1426 bytes)
    pkts bytes target     prot opt in     out     source               destination
        0     0 MASQUERADE  all  --  any    !br-84ec5b4d9561  172.18.0.0/16        anywhere
        0     0 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
        0     0 MASQUERADE  tcp  --  any    any     172.18.0.2           172.18.0.2           tcp dpt:8000
        0     0 MASQUERADE  tcp  --  any    any     172.18.0.3           172.18.0.3           tcp dpt:8000

    Chain DOCKER (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 RETURN     all  --  br-84ec5b4d9561 any     anywhere             anywhere
        0     0 RETURN     all  --  docker0 any     anywhere             anywhere
        0     0 DNAT       tcp  --  !br-84ec5b4d9561 any     anywhere             anywhere             tcp dpt:32769 to:172.18.0.2:8000
        0     0 DNAT       tcp  --  !br-84ec5b4d9561 any     anywhere             anywhere             tcp dpt:8000 to:172.18.0.3:8000
~~~

* By default all containers on the same bridge driver network will have connectivity with each other without extra configuration.
This is an aspect of most types of Docker networks
* Communication between different Docker networks is firewalled by default
 
 
#### links
* https://github.com/docker/labs/blob/master/networking/concepts/05-bridge-networks.md
* https://docs.docker.com/engine/userguide/networking/configure-dns/