Addressing and Subnetting
===

Hardware Addressing
---

* A hardware address is used to uniquely identify a host within a local network.
* Hardware addressing is a function of the Data-Link layer of the OSI model (Layer-2).
* Ethernet utilizes the 48-bit MAC address as its hardware address
* A MAC address is most often represented in hexadecimal for e.g **00:43:AB:F2:32:13**

| OUI (Organizational Unique Identifier) |  host ID |
|:--------------------------------------:|:--------:|
|                00:43:AB                | F2:32:13 |

* MAC addresses provide no mechanism to create boundaries between networks, There is no method to distinguish one network from another

Logical Addressing
---

A logical address contains two components:

* Network ID – identifies which network a host belongs to.
* Host ID – uniquely identifies the host on that network.

`IP` provides two fundamental Network layer services:
---

* Logical addressing – provides a unique address that identifies both the host, and the network that host exists on.
* Routing – determines the best path to a particular destination network, and then routes data accordingly.

### `IPv4` Addressing
* IPv4 employs a 32-bit address, which limits the number of possible addresses to 4,294,967,296.
* An IP address provides a hierarchical structure to both uniquely identify a host, and what network that host exists on.

IP address : 10011110010100001010010000000011

| 10011110 | 01010000 | 10100100 | 00000011 |
|:--------:|:--------:|:--------:|:--------:|
|    158   |    80    |    164   |     3    |

* Addresses are made up of parts, like state, city, street and finally house number. Most of the parts of an address are common to many people, like people living at same street or city. Generally only the house number and name finally differentiates between any two similar addresses

#### What is a subnet mask?
* Part of an IP address identifies the network. The other part of the address identifies the host. A subnet mask is required to provide this distinction
* Subnet mask is a 32 bit number just like an IP address and is written just like it
* A subnet mask should only have continuous 1s starting from left (MSB)

158.80.164.3 255.255.0.0

|    158   |    80    |    164   |     3    |
|:--------:|:--------:|:--------:|:--------:|
| 10011110 | 01010000 | 10100100 | 00000011 |
|    255   |    255   |     0    |     0    |
| 11111111 | 11111111 | 00000000 | 00000000 |


The first 16 bits of the subnet mask are set to 1, Thus, the first 16 bits of the address (158.80) identify the network. 
The last 16 bits of the subnet mask are set to 0. Thus, the last 16 bits of the address (164.3) identify the unique host on that network.

|           |     Host 1     |     Host 2     | Subnet Mask |                         |
|:---------:|:--------------:|:--------------:|:-----------:|:-----------------------:|
| Example 1 | 158.80.164.100 | 158.80.164.101 | 255.255.0.0 |       Same Network      |
| Example 2 | 158.80.164.100 | 158.85.164.100 | 255.255.0.0 | Not on the same network |
| Example 3 |   158.80.1.1   |   158.79.1.1   | 255.248.0.0 |            ?            |


Routing is a means of sending an IP packet between different networks.

### Classfull subnetting
* very specific subnetting architecture.

| Class | First Octet Range | Default Subnet Mask | # networks |   # hosts  |                      Example                     |
|:-----:|:-----------------:|:-------------------:|:----------:|:----------:|:------------------------------------------------:|
|   A   |      1 - 127      |      255.0.0.0      |     127    | 16,777,214 |   Address: 64.32.254.100 Subnet Mask: 255.0.0.0  |
|   B   |     128 - 191     |     255.255.0.0     |   16,384   |   65,534   |  Address: 152.41.12.195 Subnet Mask: 255.255.0.0 |
|   C   |     192 - 223     |    255.255.255.0    |  2,097,152 |     254    | Address: 207.79.233.6 Subnet Mask: 255.255.255.0 |

### Classless subnetting - CIDR (Classless Inter-Domain Routing)
* Classless Inter-Domain Routing (CIDR) is a simplified method of representing a subnet mask. 
* CIDR identifies the number of binary bits set to a 1 (or on) in a subnet mask, preceded by a slash.

### Subnetting 
* Subnetting is the process of creating new networks (or subnets) by stealing bits from the host portion of a subnet mask.

Consider the following class **?** network: 192.168.254.0/24  
The default subnet mask for this network is 255.255.255.0. This single network can be segmented, or subnetted, into multiple networks
How many bits do I need to steal to allow 10 subnets? 

How do split it to 2 subnetworks ?  

| Subnet Name | Needed Size | Allocated Size | Address | Mask | Dec Mask | Assignable Range | Broadcast |
|:-----------:|:-----------:|:--------------:|:-------:|:----:|:--------:|:----------------:|:---------:|
| A | 126 | 126 | 192.168.254.0 | /25 | 255.255.255.128 | 192.168.254.1 - 192.168.254.126 | 192.168.254.127 |
| B | 125 | 126 | 192.168.254.128 | /25 | 255.255.255.128 | 192.168.254.129 - 192.168.254.254 | 192.168.254.255 |


Before we will see how subnet mask is used when packets are routed to thier destination, let's find out what NICs are

[NICs](../02-nic/README.md)

