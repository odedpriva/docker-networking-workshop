#### let'a start by checking an engine host configuration.

skip this if you are running on native linux machine.

* on your mac: 'login' to the docker-on-mac namespace by using nsenter  
`docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh`

* or use screen
`screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty`
`screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill | screen -wipe`

let's check docker0 interfaces.
~~~
$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.024298df2024	no		veth4700952

$ ip a show docker0
14: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:70:b9:89:81 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:70ff:feb9:8981/64 scope link
       valid_lft forever preferred_lft forever
       
# we can see the subnet and range of ip addresses docker0 will assign to containers.
~~~

let see the routing table
~~~
$ ip r
default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
172.17.0.0/16 dev docker0  src 172.17.0.1
192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204

# all packets with 172.17.0.0/16 dest are routed to docker0 
~~~

now, let's check the filter iptable 
~~~
$ iptables -L -v
Chain INPUT (policy ACCEPT 50 packets, 3950 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
    0     0 DOCKER     all  --  any    docker0  anywhere             anywhere
    0     0 ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
    0     0 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
    0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere

Chain OUTPUT (policy ACCEPT 58 packets, 6697 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain DOCKER (1 references)
 pkts bytes target     prot opt in     out     source               destination

Chain DOCKER-ISOLATION (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  any    any     anywhere             anywhere

# we have 2 custom docker chains. 

~~~

now, let's check the nat iptables
~~~
$ iptables -L -t nat -v
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        anywhere

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere


# all OUTPUT ( that are not address to local ) packages will go through DOCKER chain
# all packages comming from docker0 subnet will MASQUERADE ( SNAT on leaving ) 
Masquerading is a special form of Source NAT where the source address is unknown at the time the rule is added to the tables in the kerne
Masquerading will modify the source IP address and port of the packet to be the primary IP address assigned to the outgoing interface
~~~

now, let's check the mangle iptables 
~~~
$ iptables -L -t mangle -v
Chain PREROUTING (policy ACCEPT 143 packets, 13040 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain INPUT (policy ACCEPT 137 packets, 10742 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 175 packets, 24199 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 175 packets, 24199 bytes)
 pkts bytes target     prot opt in     out     source               destination
 
# no change 

~~~




