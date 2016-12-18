### Default Docker Bridge Network
On any host running Docker Engine, there will, by default, be a local Docker network named bridge
This network is created using a bridge network driver which instantiates a Linux bridge called docker0


So let's see what happens when we create a container without specifying a network 
~~~
host $ docker run --rm -it --name c1 odedpriva/docker-networking sh
c1 $ ip a 
eth0@if19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
inet 172.17.0.2/16 scope global eth0
    valid_lft forever preferred_lft forever
inet6 fe80::42:acff:fe11:2/64 scope link
    valid_lft forever preferred_lft forever

c1 $ ip r
     default via 172.17.0.1 dev eth0
     172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.2
~~~

What is going on the host? 

~~~
docker-for-mac $ ip route
default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
172.17.0.0/16 dev docker0  src 172.17.0.1
192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204
~~~
