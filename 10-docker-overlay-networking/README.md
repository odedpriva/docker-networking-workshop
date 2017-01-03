http://www.slideshare.net/Docker/docker-networking-deep-dive
http://www.slideshare.net/Docker/docker-networking-control-plane-and-data-plane
https://www.youtube.com/watch?v=2EfOJhtjhIk
https://www.youtube.com/watch?v=2ihqKMDRkxM

####overlay driver
* An overlay network is a computer network that is built on top of another network. 
Nodes in the overlay network can be thought of as being connected by virtual or logical links, each of which corresponds to a path, perhaps through many physical links, in the underlying network

* With the overlay driver, multi-host networks are first-class citizens inside Docker without external provisioning or components

* The `overlay` driver utilizes an industry-standard VXLAN data plane that decouples the container network from the underlying physical network (the underlay)


~~~
host1 $ docker network ls
  NETWORK ID          NAME                DRIVER              SCOPE
  0d276b358a91        bridge              bridge              local
  fa884038823b        docker_gwbridge     bridge              local
  e7be1af823b5        host                host                local
  740m0rhztuer        ingress             overlay             swarm
  a8g8s9okdivi        net1                overlay             swarm
  32cd9d08fc71        none                null                local
~~~

* ingress is the routing mash network, it is the only network created on all nodes.
* the net1 network will be created on demand.
* docker_gwbridge is used as a gateway to the outer world

TCP port 2377 for cluster management communications.
TCP and UDP port 7946 for communication among nodes.
TCP and UDP port 4789 for overlay network traffic.