### Workshop Descriptions

Docker has revolutionized virtualization by abstarcting some ~15 years old Kernel tools, 
allowing developers, system admins and Devops to easily package and deliver application-in-containers 
without worring about the underlying infrastructure and application dependencies when moving from one environment to another.  

Along the way they have been using some basic linux netowrking tools ( and now windows ) that enabled container netowrking.

This workshop will intreduce general netowrking concepts, tools and docker specific netowrking model and its implementation.

### Participants Will

1. Understand basic networking concepts by using various tools such as tcpdump, ip command etc.
2. Understand the CNM ( container networking model ).
3. Understand single host container networking ( bridge driver ) and multi-host container networking ( overlay driver )

### Workshop agenda

The workshop has 2 part 

#### Part 1 - 90 minutes

- linux networking:
    - Networking models.
    - NIC
    - Routing
    - iptables
    - namespace and linux bridge
    - name resolution
    - ipvs

#### Part 2 - 90 minutes
- docker netowrk background:
    - history
    - componenets
- docker network subcommand. 
- docker network drivers:
    - bridge
    - overlay

### Knowladge Prerequisites
- Participants are expected to have expiriance with docker.
- Although I will try to cover all that is needed from networking POV, participants who have basic knowladge in the OSI or TCP/IP model, will find the workshop musch easier to follow.

### Hardware Prerequisites
- This wordshop was built on MAC Sierra, with Docker 1.12 ( tested on 1.13 ).
- Other OS ( Windows, Ubuntu etc .. ) could also benefit from both part of the Workshop but some commands will just not work. 
