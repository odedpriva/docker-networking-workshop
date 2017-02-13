### IPtables
`iptables` is a command-line firewall utility that uses policy chains to allow or block traffic.  
When a connection tries to establish itself on your system, iptables looks for a rule in its list to match it to. 
If it doesn't find one, it resorts to the default action.

On a high-level iptables might contain multiple tables. Tables might contain multiple chains.  
Chains can be built-in or user-defined. Chains might contain multiple rules. Rules are defined for the packets.

![tables_traverse](https://docs.google.com/drawings/d/1bdHGG_II5RrTF5vuE_Vwl1qkCrlZg9cC1-h17veKUv0/pub?w=405&h=687)

Following are the key points to remember for the iptables rules.

* Rules contain a criteria and a target.
* If the criteria is matched, it goes to the rules specified in the target (or) executes the special values mentioned in the target.
* If the criteria is not matched, it moves on to the next rule.


let's use local `networking` image and start a container: 

~~~
$ docker run -it --name c1 --rm --privileged -p 8000:8000 networking sh
# --rm         : delete container after we start it
# --privileged : to get iptables work ( allow access to kernel utilities )
# -p 8000:8000 : exposing port 8000 
# networking : image name
# sh : using sh shell as the conatiner process.
~~~

let's use `nc` to establish a tcp server listener
~~~
c1$ while true ; do echo this is a test | nc -l 8000 ; done &
~~~

now, let's see `filter` table
~~~
c1$ iptables -L -n -v
# -t table
# -L list 
# -n numeric output of addresses and ports
# - verbose
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

c1$ iptables -t nat -L -n -v
    Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination

    Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
~~~

`drop` all comming to connection to port 8000
~~~
$ iptables -A INPUT -p tcp --dport 8000 -j DROP
# -A INPUT: Append to INPUT chain
# -p tcp: tcp protocol
# --dport 8000: destination port 8000
# -j DROP: drop packet
~~~

**check what's the diference between DROP and REJECT**

~~~
# delete rule #1
$ iptables -D INPUT 1
~~~

#### links 
