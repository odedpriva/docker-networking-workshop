## Routing
Routing is a means of sending an IP packet from one point to another.
  
* All network devices, whether they are hosts, routers, or other types of network nodes such as network attached printers, need to make decisions about where to route TCP/IP data packets.  
* The routing table provides the configuration information required to make those decisions

![routing example](img/routing.jpg)

~~~~
$ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "ip r"
  default via 192.168.65.1 dev eth0  src 192.168.65.2  metric 204
  172.17.0.0/16 dev docker0  src 172.17.0.1
  192.168.65.0/29 dev eth0  src 192.168.65.2  metric 204
# src keyword : This is treated as a hint to the kernel about what IP address to select for a source address on outgoing packets on this interface
~~~~

#### links 
* http://linux-ip.net/html/tools-ip-route.html