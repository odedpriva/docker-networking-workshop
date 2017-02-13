### Default Docker Bridge Network
On any host running Docker Engine, there will, by default, be a local Docker network named bridge
This network is created using a bridge network driver which instantiates a Linux bridge called docker0


So let's see what happens when we create a container without specifying a network 
~~~
host $ docker run --rm -it --name c1 networking sh -c "ip a show eth0"
       118: eth0@if119: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
           link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
           inet 172.17.0.2/16 scope global eth0
              valid_lft forever preferred_lft forever
           inet6 fe80::42:acff:fe11:2/64 scope link tentative
              valid_lft forever preferred_lft forever

host $ docker run --rm -it --name c1 networking sh -c "ip r"
       default via 172.17.0.1 dev eth0
       172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.2
~~~

We can see that we are assigned an ip from the docker0 subnet, 
Our default GW is docker0
All packets destined to 172.17.X.X are routed through eth0


What's going on on the docker-for-mac? 

~~~
host $ docker run --rm -it --privileged --pid=host networking nsenter -t 1 -m -u -n -i sh -c "ip route"
                 default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
                 172.17.0.0/16 dev docker0  src 172.17.0.1
                 192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204

host $ docker run --rm -it --privileged --pid=host networking nsenter -t 1 -m -u -n -i sh -c "brctl show"
       bridge name	bridge id		STP enabled	interfaces
       docker0		8000.0242730c554e	no		veth1844ff2
~~~



