##IPtables
iptables is a command-line firewall utility that uses policy chains to allow or block traffic.  
When a connection tries to establish itself on your system, iptables looks for a rule in its list to match it to. 
If it doesn't find one, it resorts to the default action.

On a high-level iptables might contain multiple tables. Tables might contain multiple chains.  
Chains can be built-in or user-defined. Chains might contain multiple rules. Rules are defined for the packets.

![tables_traverse](img/tables_traverse.jpg)

Following are the key points to remember for the iptables rules.

* Rules contain a criteria and a target.
* If the criteria is matched, it goes to the rules specified in the target (or) executes the special values mentioned in the target.
* If the criteria is not matched, it moves on to the next rule.


let's use **odedpriva/docker-networking** docker image and start a container: 

~~~
$ docker run -it --rm --privileged -p 8000:8000 odedpriva/docker-networking sh
 
# starting an alpine container
# --rm         : delete container after we start it
# --privileged : to get iptables work ( allow access to kernel utilities )
# -p 8000:8000 : exposing port 8000 
# odedpriva/docker-networking : container name
# sh : using sh shell as the conatiner process.
~~~

~~~
# using nc to establish a tcp server listener
$ while true ; do echo this is a test | nc -l 8000 ; done &
~~~

~~~
# list NAT rules
$ iptables -t nat -L -n -v
# -t table
# -L list 
# -n numeric output of addresses and ports
# - verbose
~~~

~~~
# list filter rules
$ iptables -L -n -v
~~~

~~~
# drop all comming to connection to port 8000
$ iptables -A INPUT -p tcp --dport 8000 -j DROP
~~~

~~~
# delete rule #1
$ iptables -D INPUT 1
~~~

  
###some other useful commands  
~~~    
$ iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
 
# Append to INPUT chain
# Use module conntrack
# Check for state related, established
# jumpt to accept
~~~
~~~
$ iptables -A INPUT -p tcp --dport 22 -j ACCEPT
$ iptables -A INPUT -p tcp --dport 80 -j ACCEPT
 
# Append to INPUT chain
# Protocol TCP
# Destination port 22 and 80
# Jump to ACCEPT
~~~
~~~
$ iptables -A INPUT -j DROP / REJECT
# set the last rule to reject all other packets.
 
$ iptables -I INPUT 5 -p tcp --dport 443 -j ACCEPT
# update table.
 
$ iptables -D INPUT 6
# delete rule #6
  
$ iptables -P INPUT DROP
# change INPUT default to DROP
~~~ 

#### links 
* https://serversforhackers.com/video/firewalls-basics-of-iptables
* http://www.thegeekstuff.com/2011/01/iptables-fundamentals/
* https://www.youtube.com/watch?v=QFNgmO_mrRY
* http://www.iptables.info/en/structure-of-iptables.html
