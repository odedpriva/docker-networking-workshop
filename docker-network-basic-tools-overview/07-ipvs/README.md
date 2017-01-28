IPVS
---
[IPVS](http://www.linuxvirtualserver.org/software/ipvs.html) (IP Virtual Server) implements transport-layer load balancing inside the Linux kernel, so called Layer-4 switching
It is implemented as part of the [Linux Virtual Server](http://www.ultramonkey.org/papers/lvs_tutorial/html/) project.
* LVS is very high performance. It is able to handle upwards of 100,000 simultaneous connections. 
* It is easily able to load balance a saturated 100Mbit ethernet link using inexpensive commodity hardware. 
* It is also able to load balance saturated 1Gbit link and beyond using higher-end commodity hardware.

Layer 4 Switching works by multiplexing incoming TCP/IP connections and UDP/IP datagrams to real servers.  
Packets are received by a Linux Director and a decision is made as to which real server to foward the packet to.  
Once this decision is made subsequent packets to for the same connection will be sent to the same real server.  
Thus, the integrity of the connection is maintained.  

![ipvs-1](https://docs.google.com/drawings/d/1PDjM3ZnQQzAYcYlPB_AgxSFzOY5tN6JyG04c168EMfY/pub?w=678&h=199)

The Linux Virtual Server has three different ways of forwarding packets; 
* `network address translation` (NAT) - Packets are received from end users and the destination port and IP address are changed to that of the chosen real server
* `direct routing` - Packets from end users are forwarded directly to the real server.
* `IP-IP encapsulation` (tunnelling) - similar to `direct routing`, except that when packets are forwarded they are encapsulated in an IP packet, rather than just manipulating the ethernet frame

let's compare it other load-balancers
![ipvs Vs nginx Vs haproxy Vs ELB](https://docs.google.com/drawings/d/1N9zcqX4dPIIYYNpFYVvgILa7C2WdCohGBj2Q9M4GN7U/pub?w=952&h=591)
[taken from here](http://www.slideshare.net/Docker/kernel-load-balancing-for-docker-containers-using-ipvs)


let's start by setting up the 'lab' using `tools-ipvs.sh`
~~~
07-ipvs$ ./tools-ipvs.sh -s
~~~

![setup overview](https://docs.google.com/drawings/d/1dvXurhLWfI1ibDHxDkhP4phfSR9Vb6L9QYlrRgC2r6Y/pub?w=960&h=540)

let's check that we allow ipv4 forwarding on the director
~~~
host$ director sh -c "sysctl -a | grep net.ipv4.ip_forward"
    ...
    net.ipv4.ip_forward = 1
    ...
~~~

You can check the current state and connections of the LB using -L flag. 
~~~
host$ director ipvsadm -L
      IP Virtual Server version 1.2.1 (size=4096)
      Prot LocalAddress:Port Scheduler Flags
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
~~~

let's setup the rules
~~~
host$ director ipvsadm -A -t 1.2.3.4:8000
# -A add
# -t tcp

host$ director ipvsadm -a -t 1.2.3.4:8000 -r 10.0.0.2:8000 -m
host$ director ipvsadm -a -t 1.2.3.4:8000 -r 10.0.0.3:8000 -m
# -a add worker
# -t tcp
# -r worker IP
# -m use NAT

host$ director ipvsadm -L
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  director:8000 wlc
    -> ipvs_1.ipvs:8000             Masq    1      0          0
    -> ipvs_2.ipvs:8000             Masq    1      0          0
~~~