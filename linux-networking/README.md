linux networking
---

### Participants Will

- Build the `lab` that will be used throughout this part. 
- Refreshes and gain new knowlasdge on core Linux concepts that provide a foundation for 2nd part, such as TCP/IP, OSI, name resolution, and the IP and other tools.

![wax-on-wax-off.jpg](http://i.imgur.com/5QlICkE.gif)

### let't build the lab

Through out this part we will use 3 docker images that are all based on [alpine](https://alpinelinux.org/) linux distro. 
- networking : image that include networking tools such as tcpdump, dig, curl, etc.
- proxy : `node.js` basic server that forwards request to the server application
- server : `node.js` basic server, that returns host name.


Build the images using  
`cd workshop-images && for i in $(ls); do cd $i; docker build -t $i . ; cd .. ; done`

~~~
docker images
REPOSITORY                         TAG                                        IMAGE ID            CREATED             SIZE
server                             latest                                     7717c0bf84ac        23 minutes ago      62.9 MB
proxy                              latest                                     9f3a1d7cf612        24 minutes ago      62.9 MB
networking                         latest                                     9292c20a0203        24 minutes ago      149 MB
~~~

### What do we have now? 
![docker-for-mac](https://docs.google.com/drawings/d/112zPkz0yGVgSKYgei2pNBTYxtPAo9VG9RlDs5Efqyic/pub?w=945&h=532)

* Docker for Mac does not use VirtualBox, but rather HyperKit, a lightweight macOS virtualization solution built on top of Hypervisor.framework in macOS 10.10 Yosemite and higher 
* At installation time, Docker for Mac provisions an HyperKit VM based on Alpine Linux, running Docker Engine. It exposes the docker API on a socket in /var/run/docker.sock.

To check under-the-hood of docker-for-mac we will use [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) that is available in networking image we just built.

run this command:
`docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "ip link"`

the outputh displays docker-for-mac's alpine interfaces  
**bonus qusetion**  What is the `veth***@if***` ? 

let's use alias it to make our life easier
`alias docker-for-mac='docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c'`

Before we start with the fun fun fun .. let's refersh out memory with some academic TCP/IP model.

[TCP/IP](00-networking-models/README.md)