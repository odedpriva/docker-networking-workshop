### network with bridge driver
We will explore the bridge network deployment model
The bridge driver creates a private network internal to the host   
and provides an external port mapping on a host interface for external connectivity.

~~~
# Create a user-defined bridge network for our application 
$ docker network create -d bridge mybuilding
~~~


#### What was changed? 
~~~
another routing rule
$ ip r
  default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
  172.17.0.0/16 dev docker0  src 172.17.0.1
  172.18.0.0/16 dev br-e997739dba4c  src 172.18.0.1
  192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204  

~~~

~~~
changes in iptables filter table
$ iptables -L -v
  Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
   pkts bytes target     prot opt in     out     source               destination
  
  Chain FORWARD (policy DROP 0 packets, 0 bytes)
   pkts bytes target     prot opt in     out     source               destination
      0     0 DOCKER-ISOLATION  all  --  any    any     anywhere             anywhere
      0     0 DOCKER     all  --  any    br-e997739dba4c  anywhere             anywhere
      0     0 ACCEPT     all  --  any    br-e997739dba4c  anywhere             anywhere             ctstate RELATED,ESTABLISHED
      0     0 ACCEPT     all  --  br-e997739dba4c !br-e997739dba4c  anywhere             anywhere
      0     0 ACCEPT     all  --  br-e997739dba4c br-e997739dba4c  anywhere             anywhere
      0     0 DOCKER     all  --  any    docker0  anywhere             anywhere
      0     0 ACCEPT     all  --  any    docker0  anywhere             anywhere             ctstate RELATED,ESTABLISHED
      0     0 ACCEPT     all  --  docker0 !docker0  anywhere             anywhere
      0     0 ACCEPT     all  --  docker0 docker0  anywhere             anywhere
  
  Chain OUTPUT (policy ACCEPT 1 packets, 364 bytes)
   pkts bytes target     prot opt in     out     source               destination
  
  Chain DOCKER (2 references)
   pkts bytes target     prot opt in     out     source               destination
  
  Chain DOCKER-ISOLATION (1 references)
   pkts bytes target     prot opt in     out     source               destination
      0     0 DROP       all  --  docker0 br-e997739dba4c  anywhere             anywhere
      0     0 DROP       all  --  br-e997739dba4c docker0  anywhere             anywhere
      0     0 RETURN     all  --  any    any     anywhere             anywhere

~~~
~~~
changes in iptables nat table
$ iptables -L -v -t nat
  Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
   pkts bytes target     prot opt in     out     source               destination
      0     0 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL
  
  Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
   pkts bytes target     prot opt in     out     source               destination
  
  Chain OUTPUT (policy ACCEPT 7 packets, 1374 bytes)
   pkts bytes target     prot opt in     out     source               destination
      0     0 DOCKER     all  --  any    any     anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
  
  Chain POSTROUTING (policy ACCEPT 7 packets, 1374 bytes)
   pkts bytes target     prot opt in     out     source               destination
      0     0 MASQUERADE  all  --  any    !br-e997739dba4c  172.18.0.0/16        anywhere
      0     0 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
  
  Chain DOCKER (2 references)
   pkts bytes target     prot opt in     out     source               destination
      0     0 RETURN     all  --  br-e997739dba4c any     anywhere             anywhere
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