#### bridge driver on user defined network

In addition to the default networks, users can create their own networks called user-defined networks of any network driver type
In the case of user-defined bridge networks, Docker will create a new Linux bridge on the host.

#### User-Defined Bridge Networks

~~~
# Create a user-defined bridge network for our application 
host $ docker network create -d bridge net1 
       0b94b69e065efe462168c16a4c946bc60507cb51edf9dd730cc9aa5a5112c062
~~~
By default bridge will be assigned one subnet from the ranges 172.[17-31].0.0/16 or 192.168.[0-240].0/20   
which does not overlap with any existing host interface

* users can create their own networks called user-defined networks of any network driver type. 
* Docker will create a new Linux bridge on the host. 
* User-defined networks supports manual IP address and subnet assignment. 
* If an assignment isn't given, then Docker's default IPAM driver will assign the next subnet available in the private IP space.

~~~
docker-for-mac $ bridge name	bridge id		STP enabled	interfaces
       docker0		8000.024298df2024	no		veth7871061
       br-0b94b69e065e		8000.02425001192f	no
~~~
We can see the 2nd bridge interface

~~~
routing table
host $ ip r
       default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
       172.17.0.0/16 dev docker0  src 172.17.0.1
       172.18.0.0/16 dev br-0b94b69e065e  src 172.18.0.1
       192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204

~~~
We get another rule for the new bridge

~~~
changes in iptables filter table
host $ iptables -L -v
       Chain INPUT (policy ACCEPT 3 packets, 228 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain FORWARD (policy DROP 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
           0     0 DOCKER     all  --  any    br-0b94b69e065e  anywhere             anywhere
           0     0 ACCEPT     all  --  any    br-0b94b69e065e  anywhere             anywhere             ctstate RELATED,ESTABLISHED
           0     0 ACCEPT     all  --  br-0b94b69e065e !br-0b94b69e065e  anywhere             anywhere
           0     0 ACCEPT     all  --  br-0b94b69e065e br-0b94b69e065e  anywhere             anywhere
         313  153K DOCKER     all  --  any    docker0  anywhere             anywhere
         313  153K ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
         266 31768 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
           0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere
       
       Chain OUTPUT (policy ACCEPT 6 packets, 1320 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain DOCKER (2 references)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain DOCKER-ISOLATION (1 references)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DROP       all  --  docker0 br-0b94b69e065e  anywhere             anywhere
           0     0 DROP       all  --  br-0b94b69e065e docker0  anywhere             anywhere
         579  185K RETURN     all  --  any    any     anywhere             anywhere
~~~
Communication between different Docker networks is firewalled by default.
This is a fundamental security aspect that allows us to provide network policy using Docker networks.
~~~
changes in iptables nat table
host $ iptables -L -v -t nat
       Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL
       
       Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
        pkts bytes target     prot opt in     out     source               destination
       
       Chain OUTPUT (policy ACCEPT 10 packets, 1890 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 DOCKER     all  --  any    any     anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
       
       Chain POSTROUTING (policy ACCEPT 10 packets, 1890 bytes)
        pkts bytes target     prot opt in     out     source               destination
           0     0 MASQUERADE  all  --  any    !br-0b94b69e065e  172.18.0.0/16        anywhere
          48  3511 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
       
       Chain DOCKER (2 references)
        pkts bytes target     prot opt in     out     source               destination
           0     0 RETURN     all  --  br-0b94b69e065e any     anywhere             anywhere
           0     0 RETURN     all  --  docker0 any     anywhere             anywhere
~~~




let's start our application
~~~
# Instantiate the backend DB on mybuilding network 
$ docker run -d --net mybuilding --name db mongo

# Instantiate the proxy on mybuilding network 
$ docker run -d --net mybuilding -p 8000:8000 --name proxy odedpriva/mybuilding
~~~

//TODO add bridge-drive-1 image.


With the above commands we have deployed our application on a single host.  
The Docker bridge network provides connectivity and name resolution amongst the containers on the same bridge  
while exposing our frontend container externally.