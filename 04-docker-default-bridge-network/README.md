### Default Docker Bridge Network
On any host running Docker Engine, there will, by default, be a local Docker network named bridge
This network is created using a bridge network driver which instantiates a Linux bridge called docker0

~~~
# Create a user-defined bridge network for our application 
$ docker network create -d bridge mybuilding
~~~


