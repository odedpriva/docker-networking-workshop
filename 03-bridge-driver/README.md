Tutorial App: Bridge Driver
This model is the default behavior of the built-in Docker bridge network driver.  
The bridge driver creates a private network internal to the host and provides an external port mapping on a host interface for external connectivity.

~~~
# Create a user-defined bridge network for our application 
$ docker network create -d bridge mybuilding
~~~

####let's see what was created: 

* on your mac: enter to the docker-on-mac namespace  
`docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh`


~~~
# Instantiate the backend DB on the mybuilding network 
$ docker run -d --net mybuilding --name db mongo
~~~
~~~
# Instantiate the proxy on the mybuilding network 
$ docker run -d --net mybuilding -p 8000:8000 odedpriva/mybuilding
~~~


