This project allows a user to create a Centos VM for pre-Europa Zenoss
source-build development.  The intended usage is to perform a source build on
the guest, check out source code on the host, mount the host's source on the
guest, and link to the mounted source.  Then code can be edited on the
host and changes will be reflected on running code on the guest.  

Set up Virtualbox DHCP
----------------------
Go into Virtualbox Preferences|Network|Host Only Networks.  Create a new network (or edit existing) with the following settings:

**Adapter:**
```
IPv4 Address: 192.168.0.1
IPv4 Mask: 255.255.255.0
```
**DHCP Server:**
```
Server Address: 192.168.0.2
Server Mask: 255.255.255.0
Lower Address Bound: 192.168.0.3
Upper Address Bound: 192.168.0.254
```

Bring up the VM
---------------

    $ vagrant up

Build on the guest:
-------------------

    $ vagrant ssh
    $ sudo su - zenoss
    $ mkdir build; cd build
    $ svn co http://dev.zenoss.com/svnint/branches/core/zenoss-4.x/inst

Then perform normal configure, build, mkzenossinstance steps

Checkout on the host:
---------------------
The Vagrantfile will mount ./src as /home/zenoss/work

    $ cd ./src
    $ svn checkout http://dev.zenoss.com/svnint/branches/core/zenoss-4.x/ core
    $ svn checkout http://dev.zenoss.com/svnint/branches/zenoss-4.x/zenpacks
    $ git clone https://github.com/zenoss/ZenPacks.zenoss.Impact.git
    $ git clone https://github.com/zenoss/impact-server.git

Link from the installed to the shared files:
-----------------------

    $ vagrant ssh
    $ sudo su - zenoss
    $ ln -s /home/zenoss/work/core/Products /opt/zenoss/Products
    $ ln -s /home/zenoss/work/impact-server/target/zenoss-dsa-*.war /opt/zenoss_impact/webapps/zenoss-dsa.war
