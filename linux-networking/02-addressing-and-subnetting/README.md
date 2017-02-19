### Addressing and Subnetting

## Hardware Addressing
* A hardware address is used to uniquely identify a host within a local network. 
* Hardware addressing is a function of the Data-Link layer of the OSI model (Layer-2).
* Ethernet utilizes the 48-bit MAC address as its hardware address     
* A MAC address is most often represented in hexadecimal for e.g **00:43:AB:F2:32:13**

|  OUI (Organizational Unique Identifier) | host ID |
|--------------|-------------|
|           00:43:AB |        F2:32:13 |

* MAC addresses provide no mechanism to create boundaries between networks, There is no method to distinguish one network from another

## Logical Addressing
A logical address contains two components:
* Network ID – identifies which network a host belongs to.
* Host ID – uniquely identifies the host on that network.

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
