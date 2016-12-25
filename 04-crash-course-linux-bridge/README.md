####The Linux Bridge
A Linux bridge is a Layer 2 device that is the virtual implementation of a physical switch inside the Linux kernel.
It forwards traffic based on MAC addresses which it learns dynamically by inspecting traffic. 
Linux bridges are used extensively in many of the Docker network drivers. 


The Spanning Tree Protocol (STP) is a network protocol that builds a logical loop-free topology for Ethernet networks. 
The basic function of STP is to prevent bridge loops and the broadcast radiation that results from them

~~~
host $ docker run -d --name c1 --rm busybox busybox httpd -f -p 8000
host $ docker run -d --name c2 --rm busybox busybox httpd -f -p 8000
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