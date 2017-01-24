docker0-and-host-configuration
===
Linux bridge - A Linux bridge is a Layer 2 device that is the virtual implementation of a physical switch inside the Linux kernel.   
It forwards traffic based on MAC addresses which it learns dynamically by inspecting traffic
docker0 bridge instance has one interface, vetha****,  
which provides connectivity from the bridge to the eth0 interface inside containers.

docker-default-bridge-network
====
bridge - is the name of the Docker network
bridge - is the network driver, or template, from which this network is created
docker0 - is the name of the Linux bridge that is the kernel building block used to implement this network

A container interface's MAC address is dynamically generated and embeds the IP address to avoid collision.
[//]: # "//TODO BROADCAST"    
[//]: # "//TODO MULTICAST"  
[//]: # "//TODO UP"  
[//]: # "//TODO LOWER_UP"  