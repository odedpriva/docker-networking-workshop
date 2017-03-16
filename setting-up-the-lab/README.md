Setting up the lab
===

Through out this part we will use 3 docker images that are all based on alpine linux distro.

* networking : image that include networking tools such as tcpdump, dig, curl, etc.
* proxy : node.js basic server that forwards request to the server application
* server : node.js basic server, that returns host name.

Building the images
---

```bash
cd workshop-images
for i in $(ls); do cd $i; docker build -t $i . ; cd .. ; done
```


What do we have now?
---

![docker-for-mac](https://docs.google.com/drawings/d/112zPkz0yGVgSKYgei2pNBTYxtPAo9VG9RlDs5Efqyic/pub?w=945&h=532)


Inspecting docker-for-mac
---

To check under-the-hood of docker-for-mac we will use nsenter that is available in the networking image we just built.

* run this command:

```bash
docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c "ip link"
```

* let's create an alias to make our life easier:

```bash
alias docker-for-mac='docker run -it --privileged --pid=host networking nsenter -t 1 -n sh -c'
```