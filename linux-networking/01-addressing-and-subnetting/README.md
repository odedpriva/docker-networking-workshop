### Addressing and Subnetting

## Hardware Addressing
* A hardware address is used to uniquely identify a host within a local network. 
* Hardware addressing is a function of the Data-Link layer of the OSI model (Layer-2).
* Ethernet utilizes the 48-bit MAC address as its hardware address     
* A MAC address is most often represented in hexadecimal for e.g **00:43:AB:F2:32:13**

| OUI (Organizational Unique Identifier) |  host ID |
|:--------------------------------------:|:--------:|
|                00:43:AB                | F2:32:13 |

* MAC addresses provide no mechanism to create boundaries between networks, There is no method to distinguish one network from another

## Logical Addressing
A logical address contains two components:
* Network ID – identifies which network a host belongs to.
* Host ID – uniquely identifies the host on that network.


### `IP` provides two fundamental Network layer services:
* Logical addressing – provides a unique address that identifies both the host, and the network that host exists on.
* Routing – determines the best path to a particular destination network, and then routes data accordingly.

### `IPv4` Addressing
* IPv4 employs a 32-bit address, which limits the number of possible addresses to 4,294,967,296.
* An IP address provides a hierarchical structure to both uniquely identify a host, and what network that host exists on.

IP address : 158.80.164.3

|    158   |    80    |    164   |     3    |
|:--------:|:--------:|:--------:|:--------:|
| 10011110 | 01010000 | 10100100 | 00000011 |


* Part of an IP address identifies the network. The other part of the address identifies the host. A subnet mask is required to provide this distinction

158.80.164.3 255.255.0.0

|    158   |    80    |    164   |     3    |
|:--------:|:--------:|:--------:|:--------:|
| 10011110 | 01010000 | 10100100 | 00000011 |
| 11111111 | 11111111 | 00000000 | 00000000 |


The first 16 bits of the subnet mask are set to 1, Thus, the first 16 bits of the address (158.80) identify the network. 
The last 16 bits of the subnet mask are set to 0. Thus, the last 16 bits of the address (164.3) identify the unique host on that network.

|           |     Host 1     |     Host 2     | Subnet Mask |                         |
|:---------:|:--------------:|:--------------:|:-----------:|:-----------------------:|
| Example 1 | 158.80.164.100 | 158.80.164.101 | 255.255.0.0 |       Same Network      |
| Example 2 | 158.80.164.100 | 158.85.164.100 | 255.255.0.0 | Not on the same network |
| Example 3 |   158.80.1.1   |   158.79.1.1   | 255.248.0.0 |            ?            |


Routing is a means of sending an IP packet between different networks.

### IP Address Classes
| Class | **First** Octet Range | Default Subnet Mask | # networks |   # hosts  |                      Example                     |
|:-----:|:-----------------:|:-------------------:|:----------:|:----------:|:------------------------------------------------:|
|   A   |      1 - 127      |      255.0.0.0      |     127    | 16,777,214 |   Address: 64.32.254.100 Subnet Mask: 255.0.0.0  |
|   B   |     128 - 191     |     255.255.0.0     |   16,384   |   65,534   |  Address: 152.41.12.195 Subnet Mask: 255.255.0.0 |
|   C   |     192 - 223     |    255.255.255.0    |  2,097,152 |     254    | Address: 207.79.233.6 Subnet Mask: 255.255.255.0 |


Remember the following three rules:
* The first octet on an address dictates the class of that address.
* The subnet mask determines what part of an address identifies the network, and what part identifies the host.
* Each class has a default subnet mask. A network using its default subnet mask is referred to as a classful network.


### CIDR (Classless Inter-Domain Routing)
Classless Inter-Domain Routing (CIDR) is a simplified method of representing a subnet mask. 
CIDR identifies the number of binary bits set to a 1 (or on) in a subnet mask, preceded by a slash.
  
For example, a subnet mask of 255.255.255.240 would be represented as follows in binary:
11111111.11111111.11111111.11110000
The first 28 bits of the above subnet mask are set to 1. 
The CIDR notation for this subnet mask would thus be /28. 

### Subnet and Broadcast Addresses
On each IP network, two host addresses are reserved for special use:
* The subnet (or network) address, used to identify the network itself and its addresses contain all 0 bits in the host portion of the address.
For example, 192.168.1.0/24 is a subnet address
* The broadcast address, identifies all hosts on a particular network and its addresses contain all 1 bits in the host portion of the address.
For example, 192.168.1.255/24 is a broadcast address.

### Subnetting 

* All network devices, whether they are hosts, routers, or other types of network nodes such as network attached printers, need to make decisions about where to route TCP/IP data packets.  
* The routing table provides the configuration information required to make those decisions

![routing example](https://docs.google.com/drawings/d/1srR0yFHf3bBPyxDXSh_zMmDERhU6xdoktBy-ifVQebg/pub?w=930&h=328)

~~~~
host$ ip r
      default via 172.17.0.1 dev eth0
      172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.2
# src keyword : This is treated as a hint to the kernel about what IP address to select for a source address on outgoing packets on this interface
~~~~
