### Routing
Routing is a means of sending an IP packet from one point to another.
  
* All network devices, whether they are hosts, routers, or other types of network nodes such as network attached printers, need to make decisions about where to route TCP/IP data packets.  
* The routing table provides the configuration information required to make those decisions

![routing example](https://docs.google.com/drawings/d/1srR0yFHf3bBPyxDXSh_zMmDERhU6xdoktBy-ifVQebg/pub?w=930&h=328)

~~~~
host$ ip r
      default via 172.17.0.1 dev eth0
      172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.2
# src keyword : This is treated as a hint to the kernel about what IP address to select for a source address on outgoing packets on this interface
~~~~
