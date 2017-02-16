linux networking
---

The goal of this part is to give you a solid understanding about networking in general and linux tools in particular. 

![wax-on-wax-off.jpg](http://i.imgur.com/5QlICkE.gif)

Through out this part we will use 3 docker images all based on alpine linux distro. 
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
