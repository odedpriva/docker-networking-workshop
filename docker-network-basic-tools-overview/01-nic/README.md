### NIC 
* A network interface is the point of interconnection between a computer and a private or public network. 
* A network interface is generally a network interface card (NIC), but does not have to have a physical form.
* Instead, the network interface can be implemented in software. 
* For example, the loopback interface (127.0.0.1 for IPv4 and ::1 for IPv6) is not a physical device but a piece of software simulating a network interface

![network interface](https://docs.google.com/drawings/d/1ofppplY8hfjtnaOlcB9t1cqaPXsYfRx8P5Tj1oBWL2c/pub?w=753&h=485)

let's start by creating a contaienr
~~~
host $ docker run --rm -it --privileged --name c1 networking sh
~~~
let's use the ip command to manipulate the containers NICs

*ip* - show / manipulate routing, devices, policy routing and tunnels, The `ifconfig` command is now being deprecated and the new kid on the block is the ip command.  
The ip command is part of the `iproute2util` package. 
The ip command consolidates many different networking commands into one

we will use the `ip` command through out this workshop. 
~~~
c1 $ ip link add name dummy1 type dummy
c1 $ ip l set dummy1 up
c1 $ ip a add 10.0.0.1 dev dummy1
c1 $ ping -c 2 10.0.0.1
    PING 10.0.0.1 (10.0.0.1): 56 data bytes
    64 bytes from 10.0.0.1: seq=0 ttl=64 time=0.072 ms
    64 bytes from 10.0.0.1: seq=1 ttl=64 time=0.094 ms

    --- 10.0.0.1 ping statistics ---
    2 packets transmitted, 2 packets received, 0% packet loss
    round-trip min/avg/max = 0.072/0.083/0.094 ms
~~~
