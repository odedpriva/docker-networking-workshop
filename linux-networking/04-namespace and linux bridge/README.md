#### Network Namespace.

A Linux network namespace is an isolated network stack in the kernel with its own interfaces, routes, firewall and its own sockets isolated from other netns.


let's work on c1 container: 
`docker run -it --rm --name c1 --privileged networking sh`

![c1](https://docs.google.com/drawings/d/16qiYCBzX04XkLf8XuWlTmqZYIdMoMd9psjSCLquRXOQ/pub?w=960&h=540)



let's create a namespace:
~~~
ip netns add red
ls /var/run/netns/
#red
alias red='ip netns exec red'
~~~

let's create a veth interface and attach it to red ns
![veth interface](https://docs.google.com/drawings/d/1Jd3YAmxBTYUUDrliRw5Z48rrgV_Kc3kRGQulNvwIu4I/pub?w=964&h=523)
~~~ 
ip l add veth0 type veth peer name veth1
ip l set veth1 netns red
~~~

let steup our veth1 interface. 
~~~
red ip l set veth1 name eth0
red ip link set eth0 up
red ip a add 10.0.0.2/16 dev eth0
red ip r add default via 10.0.0.1
red ip route flush cache
red ip l set eth0 up
red ip l set dev lo up
~~~

![bridge 3](https://docs.google.com/drawings/d/16nrKZPfxwanOHFJffD9mHz9yh64ZOeE8xoa_mS-nxfk/pub?w=960&h=540)


let's see if we can `ping` interfaces outside of the namespcae.
~~~

docker exec -it c1 sh -c "ip netns exec red ping -W 1 -c1 172.17.0.2"
      PING 172.17.0.2 (172.17.0.2): 56 data bytes

      --- 172.17.0.2 ping statistics ---
      1 packets transmitted, 0 packets received, 100% packet loss


docker exec -it c1 sh -c "ip netns exec red ping -W 1 -c1 8.8.8.8"
      PING 8.8.8.8 (8.8.8.8): 56 data bytes

      --- 8.8.8.8 ping statistics ---
      1 packets transmitted, 0 packets received, 100% packet loss

~~~

One way to enable connection out of the namespace is by using linux bridge
Docker uses linux bridges to connect containers to host eth0
* A bridge is a Layer 2 device that connects two Layer 2 (i.e. Ethernet) segments together,  
A bridge is effectively a switch and all the confusion started 20+ years ago for marketing purposes.
* Linux kernel is able to perform bridging since 1999
* It forwards traffic based on MAC addresses which it learns dynamically by inspecting traffic. 
* Linux bridges are used extensively in many of the Docker network drivers. 
~~~
host$ docker run -it --rm --privileged --pid=host networking nsenter -t 1 -m -u -n -i sh -c "brctl show"
      bridge name	bridge id		STP enabled	interfaces
      docker0		8000.024206f8a7cb	no		veth820e277
                                                veth08b622c
~~~

Let's imitate the same network for our c1 and red namespace 

let create a bridge and configure it
~~~
ip l add br0 type bridge
ip l set br0 up
ip a add 10.0.0.1/16 dev br0
# check routing table .. what do you see ?
~~~

let's attach our interface to the the our bridge. 
~~~
ip l set veth0 up
ip l set veth0 master br0
# check the bridge using `brctl` command. 


![bridge 4](https://docs.google.com/drawings/d/1pN3gAltIWDikUYrYydC62cJX1uq6r7-gYcxkDy_uFbg/pub?w=960&h=540)
~~~

let's retry host and internet connectivity
~~~
docker exec -it c1 sh -c "ip netns exec red ping -W 1 -c1 172.17.0.2"
      PING 172.17.0.2 (172.17.0.2): 56 data bytes
      64 bytes from 172.17.0.2: seq=0 ttl=64 time=0.193 ms

      --- 172.17.0.2 ping statistics ---
      1 packets transmitted, 1 packets received, 0% packet loss
      round-trip min/avg/max = 0.193/0.193/0.193 ms

docker exec -it c1 sh -c "ip netns exec red ping -W 1 -c1 8.8.8.8"
      PING 8.8.8.8 (8.8.8.8): 56 data bytes

      --- 8.8.8.8 ping statistics ---
      1 packets transmitted, 0 packets received, 100% packet loss
~~~

mmm ... 

what are we missing ? 

NAT rules for outgress networking 
~~~
#iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
~~~

do we need br0 MASQUERADE also? 

and now? 
~~~
docker exec -it c1 sh -c "ip netns exec red ping -W 1 -c1 8.8.8.8"
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=36 time=1.002 ms

--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.002/1.002/1.002 ms

~~~

remember we mentioned layer 2 connectivity? 

~~~

docker exec -it c1 sh -c "ip netns exec red arping -c1 172.17.0.2"
      ARPING to 172.17.0.2 from 10.0.0.2 via eth0
      Unicast reply from 172.17.0.2 [6E:E7:2D:D2:6F:14] 0.026ms
      Sent 1 probe(s) (1 broadcast(s))
      Received 1 replies (0 request(s), 0 broadcast(s))
~~~