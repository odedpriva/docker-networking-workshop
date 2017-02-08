docker-networking-workshop
![network models](https://docs.google.com/drawings/d/1Gr_4a7kMwr1o619jwChy8ZW9lV66d_TwX4-lBnHydKE/pub?w=652&h=371)
===
## Workshop agenda

###let's start by going over some basic network concepts and related linux tools.
01-crash-course-routing

 

###Now that we got that covered let's see how Docker are using these tools. 

###The Container Networking Model

####libnetwork
[libnetwork](https://github.com/docker/libnetwork/) provides a native Go implementation for connecting containers
The goal of libnetwork is to deliver a robust Container Network Model that provides a consistent programming interface and the required network abstractions for applications.

![cnm]("./img/cnm-model.png")

There are several high-level constructs in the CNM. They are all OS and infrastructure agnostic so that applications can have a uniform experience no matter the infrastructure stack.

Sandbox — A Sandbox includes management of the container's interfaces, routing table, and DNS settings.  
An implementation of a Sandbox could be a Linux Network Namespace, a FreeBSD Jail, or other similar concept.
Endpoint — An Endpoint joins a Sandbox to a Network.  
The Endpoint construct exists so the actual connection to the network can be abstracted away from the application. 
This helps maintain portability so that a service can use different types of network drivers without being concerned with how it's connected to that network.
Network — The CNM does not specify a Network in terms of the OSI model.   
An implementation of a Network could be a Linux bridge, a VLAN, etc. 
A Network is a collection of endpoints that have connectivity between them.

####Categories of Network Drivers
* Network Drivers - Docker Network Drivers provide the actual implementation that makes networks work, 
Docker offers both native (Bridge, Overlay, MACVLAN, Host, None) and 'plugin' network drivers such as [contiv]('http://contiv.github.io/'), [weave]("https://www.weave.works/docs/net/latest/introducing-weave/")
Network scope is the domain of the driver which can be the local or swarm scope.
* IPAM Drivers -  Docker has a built-in IP Address Management Driver that provides default subnets or IP addresses for Networks and Endpoints if they are not specified


#### 04-docker0-and-host-configuration


#### 05-docker-bridge-network


#### 06-docker-bridge-private-network




#### network model Vs other tools
http://blog.kubernetes.io/2016/01/why-Kubernetes-doesnt-use-libnetwork.html