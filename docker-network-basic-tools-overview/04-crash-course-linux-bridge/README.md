####The Linux Bridge
* A bridge is a Layer 2 device that connects two Layer 2 (i.e. Ethernet) segments together, A bridge is effectively a switch and all the confusion started 20+ years ago for marketing purposes.
* A Linux bridge is a Layer 2 device that is the virtual implementation of a physical switch inside the Linux kernel.
* Linux kernel is able to perform bridging since 1999
* It forwards traffic based on MAC addresses which it learns dynamically by inspecting traffic. 
* Linux bridges are used extensively in many of the Docker network drivers. 

![bridge](img/bridge.png)

~~~
host$ docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "brctl show"
      bridge name	bridge id		STP enabled	interfaces
      docker0		8000.02424fd38028	no		veth0a92f2b
~~~

~~~
host $ docker run -d --name c1 --rm busybox busybox httpd -f -p 8000
host $ docker run -d --name c2 --rm busybox busybox httpd -f -p 8000
host $ docker run -it --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "brctl show"
       bridge name	bridge id		STP enabled	interfaces
       docker0		8000.02424fd38028	no		veth4ba279d
       							                veth7dba3c6
       							                veth404d0d8
       							                
host $ docker exec c1 ping -c 1 $(docker inspect c2 -f  '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
       PING 172.17.0.3 (172.17.0.3): 56 data bytes
       64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.102 ms
       
       --- 172.17.0.3 ping statistics ---
       1 packets transmitted, 1 packets received, 0% packet loss
       round-trip min/avg/max = 0.102/0.102/0.102 ms

host $ docker exec c1 arping -c 1 $(docker inspect c2 -f  '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
       ARPING to 172.17.0.3 from 172.17.0.2 via eth0
       Unicast reply from 172.17.0.3 [02:42:ac:11:00:03] 0.009ms
       Unicast reply from 172.17.0.3 [02:42:ac:11:00:03] 336.816ms
       Sent 1 probe(s) (1 broadcast(s))
       Received 2 reply (0 request(s), 0 broadcast(s))


~~~


#### links
* http://hicu.be/bridge-vs-macvlan