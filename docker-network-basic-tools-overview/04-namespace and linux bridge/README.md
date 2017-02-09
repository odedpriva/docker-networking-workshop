#### Network Namespace.

A Linux network namespace is an isolated network stack in the kernel with its own interfaces, routes, firewall and its own sockets isolated from other netns.


let's work on c1 container: 
`host$ docker run -it --rm --name c1 --privileged networking sh`

let's create 2 namespaces:
~~~
ip netns add red
ls /var/run/netns/
red
alias red='ip netns exec red'
~~~

let's create a veth interface and attach it to red ns
![veth interface](https://docs.google.com/drawings/d/1Jd3YAmxBTYUUDrliRw5Z48rrgV_Kc3kRGQulNvwIu4I/pub?w=964&h=523)
~~~ 
ip l add veth0 type veth peer name veth1
ip l set veth1 netns red
red ip l set veth1 name eth0
red ip a add 10.0.0.2/32 dev eth0
red ip link set eth0 up
red ip r add default via 10.0.0.1
red ip route flush cache
ip l set veth0 up
~~~

Docker uses linux bridges to connect containers to host eth0
* A bridge is a Layer 2 device that connects two Layer 2 (i.e. Ethernet) segments together,  
A bridge is effectively a switch and all the confusion started 20+ years ago for marketing purposes.
* Linux kernel is able to perform bridging since 1999
* It forwards traffic based on MAC addresses which it learns dynamically by inspecting traffic. 
* Linux bridges are used extensively in many of the Docker network drivers. 
~~~
host$ docker run -it --rm --privileged --pid=host networking nsenter -t 1 -m -u -n -i sh -c "brctl show"
      bridge name	bridge id		STP enabled	interfaces
      docker0		8000.02424fd38028	no		veth0a92f2b
~~~

so let's do the same for our c1 container. 

~~~
ip l add br0 type bridge
ip l set br0 up
ip a add 10.0.0.1/16 dev br0
ip l set veth0 master br0
~~~


/ # iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
/ # iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


let's check connectivity
ping eth0 from network namespace
`docker exec -it c1 sh -c "ip netns exec red ping 172.17.0.2"`
ping 8.8.8.8 from network namespace
`docker exec -it c1 sh -c "ip netns exec red ping 8.8.8.8"`

Network namespaces ensure that two containers on the same host will not be able to communicate with each other or even the host itself unless configured to do so via Docker networks


you can follow the process below to show layer2 connectivity using arping. 
Create 2 containers
~~~
host $ docker run -d --name c1 --rm busybox sleep 1200
host $ docker run -d --name c2 --rm busybox sleep 1200
host $ docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "brctl show"
       bridge name	bridge id		STP enabled	interfaces
       docker0		8000.02424fd38028	no		veth4ba279d
       							                veth7dba3c6
       							                veth404d0d8
~~~       							                

validate ping is working 
~~~
host $ docker exec c1 ping -c 1 $(docker inspect c2 -f  '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
       PING 172.17.0.3 (172.17.0.3): 56 data bytes
       64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.102 ms
       
       --- 172.17.0.3 ping statistics ---
       1 packets transmitted, 1 packets received, 0% packet loss
       round-trip min/avg/max = 0.102/0.102/0.102 ms
~~~


and now with arping.
~~~
host $ docker exec c1 `arping` -c 1 $(docker inspect c2 -f  '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
       ARPING to 172.17.0.3 from 172.17.0.2 via eth0
       Unicast reply from 172.17.0.3 [02:42:ac:11:00:03] 0.009ms
       Unicast reply from 172.17.0.3 [02:42:ac:11:00:03] 336.816ms
       Sent 1 probe(s) (1 broadcast(s))
       Received 2 reply (0 request(s), 0 broadcast(s))
~~~