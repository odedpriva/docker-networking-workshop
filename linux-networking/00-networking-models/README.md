Ntworking models
===

Layers model is a theoretical approach that describe how data is going to be transmit over the network. 
There are several layer models available, and here we will cover 2:

- TCP/IP Protocol Suite
- OSI model

#### OSI model ( Open System Interconnection )
* The OSI model is a standard of the International Organization for Standardization (ISO). 
* It was published in 1984 by both the ISO, as standard ISO 7498
* It is a general-purpose paradigm for discussing or describing how computers communicate with one another over a network. 
* Its seven-layered approach to data transmission divides the many operations up into specific related groups of actions at each layer.

![OSI - 2](https://docs.google.com/drawings/d/1HGrLyjASKeulud2DER2scDpC9GxWVRG7Hs0O8VYBUoE/pub?w=1142&h=870)

<center>**A**ll **P**eople **S**eem **t**o **N**eed **D**ata **P**rocessing</center>
---

![OSI - 3](https://docs.google.com/drawings/d/1hIawmdk7ZvwrRL0AaPdn1afQsL2aLFnkKQq2V1Wryys/pub?w=919&h=329)

We will use the OSI model to describe what happens when you click a link in a web page in your web browser

| Layer        | Example     | Functionality                                                                                                                                                                                                                                                                                                                                                                      |
|:--------------------------------------:|:--------------------------------------:|:--------------------------------------|
| APPLICATION  | Web Browser | The web browser is an APPLICATION. The web browser application gives you the means to select a web server, contact the server and request a web page. The web browser handles the process of finding the web server (the remote computer that has the web page you want stored on it) , requesting the desired web page and displaying all the files contained within the web page |
| PRESENTATION | HTTP        | The web browser handles PRESENTATION of the web page to the user by converting the files stored at the web server into formats used to display them on your computer.                                                                                                                                                                                                              |
| SESSION      |             | When you request a web page, the web browser opens a TCP connection to the web server and might open additional connections for additional resources , Each TCP connection is a SESSION.                                                                                                                                                                                           |
| TRANSPORT    | TCP         | To communicate with a web server your computer must open a TCP connection to the web server and request a web page. The TCP connection breaks up theweb page into managable chunks, lables them with numbers so they can be reassembled in the correct order and TRANSPORTS the pieces across the correct SESSION.                                                                 |
| NETWORK      | IP          | Internet Protocol (IP) is a NETWORK layer protocol that uses unique addresses for the web server and for your computer. IP provides the means for your computer to determine whether the web server is a local computer or a computer located somewhere on the Internet.                                                                                                           |
| DATA LINK    |             | Once the request from your web browser has been created it is sent to the network card. At Data Link layer, data packets are encoded and decoded into bits                                                                                                                                                                                                                         |
| PHYSICAL     |             | Physical layer conveys the bit stream - electrical impulse, light or radio signal -- through the network at the electrical and mechanical level                                                                                                                                                                                                                                    |

### TCP/IP Protocol Suite
* TCP/IP is the most popular networking protocol in existence.
* It can be found just about on any device that supports network connectivity in one form or another.
* Although refered as `protocol`, it's actually a `protocol suite` made up of several individual protocols.
* TCP/IP also is a layered protocol but does not use all of the OSI layers, though the layers are equivalent in operation and function`

![TCP/IP](https://docs.google.com/drawings/d/1lpgtyNne6RtAB-2_XM_ffy7x6e1wnEqw_78NQ4Tx_e0/pub?w=625&h=479)

![networking model](https://docs.google.com/drawings/d/1Gr_4a7kMwr1o619jwChy8ZW9lV66d_TwX4-lBnHydKE/pub?w=652&h=371)

Let's move on and go over some advanced netwokring concepts
[addressing and subnetting](../01-addressing-and-subnetting/README.md)



links
---
* [what-s-difference-between-osi-seven-layer-network-model-and-tcpip](http://electronicdesign.com/what-s-difference-between/what-s-difference-between-osi-seven-layer-network-model-and-tcpip)


