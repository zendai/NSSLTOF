NSSL2F, The NSSCACHE for Solaris 10+
------------------------------------

This tool was inspired by NSSCACHE [1].

[1] https://code.google.com/p/nsscache/

NSSCACHE was written in Python, but unfortunately on Solaris 10+ 'bsddb' is not part of the
base modules so it won't run. Obviously you can compile your own Python, install bsddb 
module (which required the db package from Oracle), but all the solutions are somewhat painful, 
mainly because you need a compiler and most likely you can only get gcc, not cc. Also tried to download
a compiled Python from CSW, it works with the newer Solaris 10s, but not with the elder ones (it will
fail to run on Solaris updates when inet_aton was not included in the libraries, these are mainly the early 
versions of Solaris 10).

Long story short, I spent a few days trying to make NSSCACHE work on Solaris 10+, without success, I also
had to consider a solution which can be mass applied to a huge amount of servers, so I decided to write my 
own version, NSSL2F which is specific to Solaris 10+. This tool is a daemon which periodically syncs (either 
full or incremental) LDAP objects into files (/etc/<database>.cache), and the package also includes an NSS 
backend to use those cache files in /etc/nsswitch.conf.

The NSS backend has to be compiled, but it's very short and simple so I won't expect any incompatibilities
among different Solaris 10 updates, so you can just compile it on one and copy it to the rest.

sendai, 2013.
