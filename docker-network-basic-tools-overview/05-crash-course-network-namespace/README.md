#### Network Namespace.

A Linux network namespace is an isolated network stack in the kernel with its own interfaces, routes, and firewall rules.
Network namespaces ensure that two containers on the same host will not be able to communicate with each other or even the host itself unless configured to do so via Docker networks


let's create 2 net namespaces:
~~~

vagrant $ ip netns add red
vagrant $ ip netns add green
vagrant $ ls -la /var/run/netns/

vagrant $ ip netns exec red ip link
          1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
              link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
~~~

let's create a bridge interface.

~~~
              
vagrant $ brctl addbr bridge1
vagrant $ brctl show
          bridge name	bridge id		STP enabled	interfaces
          bridge1		8000.000000000000	no
          
~~~

let's create a veth interface and connect it to the red NS

~~~

vagrant $ ip link add eth0-r type veth peer name veth-r
vagrant $ ip link set eth0-r netns red 
vagrant $ ip link show eth0-r
          Device "eth0-r" does not exist.
          
vagrant $ ip netns exec red ip link
          1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1
              link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
          6: eth0-r@if5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
              link/ether da:17:b0:91:8e:f0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
~~~
let's connect the veth-r interface to the bridge.
~~~
vagrant $ brctl addif bridge1 veth-r
vagrant $ brctl show bridge1
          bridge name	bridge id		STP enabled	interfaces
          bridge1		8000.76e30babf6eb	no		veth-r

~~~
let's repeat the process for the green NS. 
~~~
vagrant $ ip link add eth0-g type veth peer name veth-g
vagrant $ ip link set eth0-g netns green 
vagrant $ brctl addif bridge1 veth-g
vagrant $ brctl show bridge1
          bridge name	bridge id		STP enabled	interfaces
          bridge1		8000.5e27f1ab5117	no		veth-g
          							                veth-r
~~~
let's start and assign all red interfaces.
~~~

vagrant $ ip link set veth-r up
vagrant $ ip netns exec red ip link set dev lo up
vagrant $ ip netns exec red ip link set dev eth0-r up
vagrant $ ip netns exec red ip a add 10.0.0.1/24 dev eth0-r
vagrant $ ip netns exec red ip a
          1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
              link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
              inet 127.0.0.1/8 scope host lo
                 valid_lft forever preferred_lft forever
              inet6 ::1/128 scope host
                 valid_lft forever preferred_lft forever
          6: eth0-r@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
              link/ether da:17:b0:91:8e:f0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
              inet 10.0.0.1/24 scope global eth0-r
                 valid_lft forever preferred_lft forever
              inet6 fe80::d817:b0ff:fe91:8ef0/64 scope link
                 valid_lft forever preferred_lft forever

~~~
and the same for the green one
~~~
vagrant $ ip link set veth-g up
vagrant $ ip netns exec green ip link set dev lo up
vagrant $ ip netns exec green ip link set dev eth0-g up
vagrant $ ip netns exec green ip a add 10.0.0.2/24 dev eth0-g
vagrant $ ip netns exec green ip a
          1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
              link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
              inet 127.0.0.1/8 scope host lo
                 valid_lft forever preferred_lft forever
              inet6 ::1/128 scope host
                 valid_lft forever preferred_lft forever
          10: eth0-g@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
              link/ether de:28:59:52:9d:4f brd ff:ff:ff:ff:ff:ff link-netnsid 0
              inet 10.0.0.2/24 scope global eth0-g
                 valid_lft forever preferred_lft forever
              inet6 fe80::dc28:59ff:fe52:9d4f/64 scope link
                 valid_lft forever preferred_lft forever

~~~


~~~

vagrant $ ip netns exec red ping -c 1 10.0.0.2
          PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
          64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.053 ms
          
          --- 10.0.0.2 ping statistics ---
          1 packets transmitted, 1 received, 0% packet loss, time 0ms
          rtt min/avg/max/mdev = 0.053/0.053/0.053/0.000 ms

~~~