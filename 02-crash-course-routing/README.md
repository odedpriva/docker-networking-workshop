## Routing
Routing is a means of sending an IP packet from one point to another.
  
* All network devices, whether they are hosts, routers, or other types of network nodes such as network attached printers, need to make decisions about where to route TCP/IP data packets.  
* The routing table provides the configuration information required to make those decisions

~~~~
# there are some command to list the route table. 
$ netstat -rn
$ route
$ ip r
~~~~
~~~~
$ ip r
default via 172.17.0.1 dev eth0
172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.2

# The network 172.17.0.0/16 is available on eth0 with a scope of link, 
  which means that the network is valid and reachable through this device (eth0).  
# Note that any destination which is reachable through a gateway appears in the routing table output with the keyword via.
# src keyword : This is treated as a hint to the kernel about what IP address to select for a source address on outgoing packets on this interface
~~~~

#### links 
* http://linux-ip.net/html/tools-ip-route.html