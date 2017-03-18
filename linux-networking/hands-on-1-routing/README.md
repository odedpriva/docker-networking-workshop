Local JIRS issue. ( from Ironsource network)
===

This is an issue we faced when we first implemented Docker@ironsource.

The Problem:

From your host, from ironsource netework, try to ping Jira

~~~bash
PING jira.ironsrc.com (172.17.17.4): 56 data bytes
64 bytes from 172.17.17.4: icmp_seq=0 ttl=63 time=0.420 ms

--- jira.ironsrc.com ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.420/0.420/0.420/0.000 ms
~~~

Now, start a container, and try to ping jira using it's ip

~~~bash
docker run --rm --name c1 -it networking ping -c1 172.17.17.4
PING 172.17.17.4 (172.17.17.4): 56 data bytes

--- 172.17.17.4 ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss
~~~

What's going on ? how can we solve it?

Hints
---

1. Start by figuring out what is docker0 subnet. `docker inspect --type network bridge -f '{{(index .IPAM.Config 0).Subnet}}'`.
1. Now, any idea what is the issue?
1. Check docker-for-mac routing table.
    ~~~~bash
    docker-for-mac "ip route"
    ~~~~
1. To check a container routing table:
    ~~~~bash
    docker run --rm --name c1 -it networking sh -c 'ip route'
    ~~~~

Solution
---