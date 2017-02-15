## let'a start by checking an engine host configuration.

let's check the initial configraion for host with docker installed.

#### interfaces
~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "ip a show eth0"
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether c0:ff:ee:c0:ff:ee brd ff:ff:ff:ff:ff:ff
    inet 192.168.65.2/29 brd 192.168.65.7 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::adf4:f901:15c5:ac13/64 scope link
       valid_lft forever preferred_lft forever
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "ip a show docker0"
14: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:fb:86:a5:da brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:fbff:fe86:a5da/64 scope link
       valid_lft forever preferred_lft forever
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "brctl show "
    bridge name	bridge id		STP enabled	interfaces
    docker0		8000.0242fb86a5da	no		veth6d47d73
~~~

#### routing

~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "ip r "
default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
172.17.0.0/16 dev docker0  proto kernel  scope link  src 172.17.0.1
192.168.65.0/29 dev eth0  proto kernel  scope link  src 192.168.65.2  metric 204

# all packets with 172.17.0.0/16 dest are routed to docker0 
~~~

#### iptables - filter
~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -L -v -n "
Chain INPUT (policy ACCEPT 386 packets, 29446 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DOCKER-ISOLATION  all  --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 DOCKER     all  --  *      docker0  0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  *      docker0  0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     all  --  docker0 !docker0  0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  docker0 docker0  0.0.0.0/0            0.0.0.0/0

Chain OUTPUT (policy ACCEPT 516 packets, 75922 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain DOCKER (1 references)
 pkts bytes target     prot opt in     out     source               destination

Chain DOCKER-ISOLATION (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
~~~

#### iptables - nat
~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -L -t nat -v -n "
Chain PREROUTING (policy ACCEPT 6 packets, 2538 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 498 packets, 70551 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT 498 packets, 70551 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
~~~

#### iptables - mangle

~~~
docker run -it --rm --privileged --pid=host networking nsenter -t 1 -n sh -c "iptables -t mangle -L -v -n "
Chain PREROUTING (policy ACCEPT 396 packets, 32982 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain INPUT (policy ACCEPT 388 packets, 29598 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 519 packets, 76437 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 519 packets, 76437 bytes)
 pkts bytes target     prot opt in     out     source               destination
 
# no change 

~~~




