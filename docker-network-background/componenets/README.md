#### Docker CNM
Formalizes the steps required to provide networking for containers while providing an abstraction that can be used to support multiple network drivers

* CNM is a spec proposed by Docker. 
* Another netowrking model is [CNI](https://github.com/containernetworking/cni/blob/master/SPEC.md)
* CNM --> [libnetwork](https://github.com/docker/libnetwork) --> Drivers

|             | CNM                                                         | CNI                                                 |
|-------------|-------------------------------------------------------------|-----------------------------------------------------|
| Proposed By | Docker                                                      | CoreOS - part of the App Container specification    |
| Plugin      | Plugin Friendly                                             | Plugin system still retains its "alpha" designation |
| kv store    | internal, based on [libkv](https://github.com/docker/libkv) | consul, etcd or zookeeper                           |
| DNS         | internal, based on docker engine.                           | skydns, DNS service discovery for etcd              |


CNM
---

* Sandbox

A Sandbox contains the configuration of a container's network stack. This includes management of the container's interfaces, routing table and DNS settings.   
An implementation of a Sandbox could be a `Linux Network Namespace`, a `FreeBSD Jail` or other similar concept. A Sandbox may contain many endpoints from multiple networks.

* Endpoint

An Endpoint joins a Sandbox to a Network. An implementation of an Endpoint could be a `veth pair`, an `Open vSwitch` internal port or similar. 
An Endpoint can belong to only one network but may only belong to one Sandbox.

* Network

A Network is a group of Endpoints that are able to communicate with each-other directly. 
An implementation of a Network could be a `Linux bridge`, a `VLAN`, etc. Networks consist of many endpoints.

libnetwork
---
Real world implementation of CNM by Docker.
Written in Go, it is the one place for all Docker networking logic.  
libnetwork uses a driver / plugin model to support many networking solutions available to suit a broad range of use-cases.

Drivers
---
Network specific details. 
Drivers enable Engine deployments to be extended to support a wide range of networking technologies, such as `VXLAN`, `IPVLAN`, `MACVLAN` or something completely different.

Libnetwork implement the Contorl and Management plane While Drivers implement the Data plane
![CNM - 1](https://docs.google.com/drawings/d/1h2rCjlvgF5VFXkYh4WVCw1geinMNUPLZHh36ij3FXOY/pub?w=820&h=686)

### links
* http://blog.kubernetes.io/2016/01/why-Kubernetes-doesnt-use-libnetwork.html
* https://app.pluralsight.com/library/courses/docker-networking/table-of-contents