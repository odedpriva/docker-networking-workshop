IPtables
--- 

`iptables` is a user-space application program that allow to configure tables provided by the Linux kernel firewall and the chains and rules it stores

There are 5 tables : filter, nat, mangle, raw, security

We are intrested in the following 3: 

|             |   filter <br> This is the default table   | nat <br> This table is consulted when a packet that creates a new connection is encountered | mangle <br> This table is used for specialized packet alteration |
|:-----------:|:------------------------------------:|:---------------------------------------------------------------------------------------:|:-----------------------------------------------------------:|
|    INPUT    |   packets destined to local sockets  |                                                                                         |              packets coming into the box itself             |
|   FORWARD   | packets being routed through the box |                                                                                         |        altering packets being routed through the box        |
|    OUTPUT   |       locally-generated packets      |                    altering locally-generated packets before routing                    |      altering locally-generated packets before routing      |
|  PREROUTING |                                      |                         altering packets as soon as they come in                        |           altering incoming packets before routing          |
| POSTROUTING |                                      |                       altering packets as they are about to go out                      |         altering packets as they are about to go out        |

![tables_traverse](https://docs.google.com/drawings/d/1c_U85mqDztLmU3C7ArY4uMh2mRBE5f3XKuIczvTO1_s/pub?w=911&h=308)

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

next section, [namespcae and linux bridging](../05-namespace-and-linux-bridge/README.md)


#### links 
http://www.faqs.org/docs/iptables/traversingoftables.html