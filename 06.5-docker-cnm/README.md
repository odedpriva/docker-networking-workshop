#### docker CNM
Formalizes the steps required to provide networking for containers while providing an abstraction that can be used to support multiple network drivers

Sandbox

A Sandbox contains the configuration of a container's network stack. This includes management of the container's interfaces, routing table and DNS settings.   
An implementation of a Sandbox could be a Linux Network Namespace, a FreeBSD Jail or other similar concept. A Sandbox may contain many endpoints from multiple networks.

Endpoint

An Endpoint joins a Sandbox to a Network. An implementation of an Endpoint could be a veth pair, an Open vSwitch internal port or similar. 
An Endpoint can belong to only one network but may only belong to one Sandbox.

Network

A Network is a group of Endpoints that are able to communicate with each-other directly. 
An implementation of a Network could be a Linux bridge, a VLAN, etc. Networks consist of many endpoints.


and to make it more simple : 
snadbox is a container, endpoint is a network interface, network is the virtual entity that connect container to container, container to vlan ... 