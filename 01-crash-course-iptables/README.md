##IPtables
iptables is a command-line firewall utility that uses policy chains to allow or block traffic.  
When a connection tries to establish itself on your system, iptables looks for a rule in its list to match it to. 
If it doesn't find one, it resorts to the default action.

let's use **odedpriva/docker-networking** docker image and start a container: 

![GitHub Logo](/images/giphy.gif)

~~~
docker run -it --rm --privileged -p 8000:8000 odedpriva/docker-networking sh
 
# starting an alpine container
# --rm         : delete container after we start it
# --privileged : to get iptables work
# -p 8000:8000 : exposing port 8000 
# odedpriva/docker-networking : container name
# sh : using sh shell as the conatiner process.

~~~


~~~
>> iptables -L -v
# list rules
~~~
~~~
>> iptables -A INPUT -i lo -j ACCEPT
# Append to INPUT chain
# interface loopback
# jump to ACCEPT target [packets get SENT somewhere]
~~~
  
~~~    
>> iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
 
# Append to INPUT chain
# Use module conntrack
# Check for state related, established
# jumpt to accept
~~~
~~~
>> iptables -A INPUT -p tcp --dport 22 -j ACCEPT
>> iptables -A INPUT -p tcp --dport 80 -j ACCEPT
 
# Append to INPUT chain
# Protocol TCP
# Destination port 22 and 80
# Jump to ACCEPT
~~~
~~~
>> iptables -A INPUT -j DROP / REJECT
# set the last rule to reject all other packets.
 
>> iptables -I INPUT 5 -p tcp --dport 443 -j ACCEPT
# update table.
 
>> iptables -D INPUT 6
# delete rule #6
  
>> iptables -P INPUT DROP
#change INPUT default to DROP
~~~ 

  
~~~
# using nc to establish a tcp server listener
>> while true ; do nc -l 8000 < /tmp/index.html ; done
~~~


#### links 
* https://serversforhackers.com/video/firewalls-basics-of-iptables 