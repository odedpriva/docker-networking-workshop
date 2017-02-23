Resolving Logical Addresses to Hardware Addresses
---
* A host cannot directly send data to another host’s logical address. 
* A destination logical address must be mapped to a hardware address, so that the Data-Link layer can package a frame to transmit on the physical medium.

### Address Resolution Protocol (ARP)
* ARP allows a host to determine the MAC address for a particular destination IP address

Let's see the following examples: 

![e.g 1](https://docs.google.com/drawings/d/1-yzBpoUYANWcTmFZSDZbfwUg00cZFtEvQSM03J9fEls/pub?w=934&h=351)

1. First, HostA will determine if the destination IP address of 10.1.1.6 is itself. If that address is configured on a local interface, the packet never leaves HostA. In this example, 10.1.1.6 is not locally configured on HostA.
2. Next, HostA will determine if the 10.1.1.6 address is on the same network or subnet as itself. HostA consults its local `routing table` to make this determination. In this example, the subnet mask is /16. Thus, HostA’s IP address of 10.1.1.5 and the destination address of 10.1.1.6 are on the same network (10.1).
3. Because HostA and HostB are on the same network, HostA will then broadcast an `ARP request`, asking for the MAC address of the 10.1.1.6 address.
4. HostB responds to the ARP request with an ARP reply, containing its MAC address (AAAA.BBBB.CCCC).
5. HostA can now construct a Layer-2 frame, with a destination of HostB’s MAC address. HostA forwards this frame to the switch, which then forwards the frame to HostB.

![e.g 2](https://docs.google.com/drawings/d/1gpYgnPG2oGsNa5J8WsTG96uUAeQVtt4R0CEkvbcS0d0/pub?w=904&h=155)

1. Again, HostA will determine if the destination IP address of 10.2.1.5 is itself. In this example, 10.2.1.5 is not locally configured on HostA.
2. Next, HostA will determine if the 10.2.1.5 address is on the same network or subnet as itself. In this example, the subnet mask is /16. Thus, HostA’s IP address of 10.1.1.5 and the destination address of 10.2.1.5 are not on the same network.
3. Because HostA and HostB are not on the same network, HostA will parse its local routing table for a route to this destination network of 10.2.x.x/16. Hosts are commonly configured with a default gateway to reach all other destination networks.
4. HostA determines that the 10.1.1.1 address on RouterA is its default gateway. HostA will then broadcast an ARP request, asking for the MAC address of the 10.1.1.1 address.
5. RouterA responds to the ARP request with an ARP reply containing its MAC address (4444.5555.6666). HostA can now construct a Layer-2 frame, with a destination of RouterA’s MAC address.
6. Once RouterA receives the frame, it will parse its own routing table for a route to the destination network of 10.2.x.x/16. It determines that this network is directly attached off of its Ethernet2 interface. RouterA then broadcasts an ARP request for the 10.2.1.5 address.
7. HostB responds to the ARP request with an ARP reply containing its MAC address (AAAA.BBBB.CCCC). RouterA can now construct a Layer-2 frame, with a destination of HostB’s MAC address.

### Local JIRS issue. ( from Ironsource network)
From your host, try to ping Jira 
~~~
PING jira.ironsrc.com (172.17.17.4): 56 data bytes
64 bytes from 172.17.17.4: icmp_seq=0 ttl=63 time=0.420 ms

--- jira.ironsrc.com ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.420/0.420/0.420/0.000 ms
~~~

Now, start a container, and try to ping jira using it's ip
~~~
docker run --rm --name c1 -it networking ping -c1 172.17.17.4
PING 172.17.17.4 (172.17.17.4): 56 data bytes

--- 172.17.17.4 ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss
~~~

What's going on ? how can we solve it? 

Hints : 
1. check the routing tables and visualize the route the ICMP package is using. 
2. to check the 
~~~~
docker run --rm --name c1 -it networking ip r
~~~~
check the routing tables 
http://www.dscentral.in/2011/07/14/understanding-ip-address-and-subnet-mask/

