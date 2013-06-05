## NSSL2F, The NSSCACHE for Solaris 10+ ##

**NSSL2F** intends to ease the NSS initiated LDAP load on Solaris 10+ hosts by providing two layers (the sync layer and the nss layer) as a replacement. If you ever had to face problems with the 'ldap' module in nsswitch.conf, you may have wondered if there is a chance to cache LDAP results locally on the server.

## The motivation ##

Well, that's what NSCD is for you might say, and partly you are correct. In theory NSCD *should* efficiently cache the results from any NSS2 compliant source backend in nsswitch but in real life this is *unfortunately not fully true*, because 

- NSCD can and eventually will crash
- probably you have a 3rd party NSS backend which is not NSS2 compatible (like Likewise's 'lsass' module) meaning NSCD will reject caching
- even if none of the previous ones are affecting you, still there are a few NSS library calls which are simply not cached/supported by NSCD, like _getgroupsbymember().

## Inspired by NSSCACHE ##

We are not the first one to realize this issue, Google came to the same conclusion, that's why they came up with [NSSCACHE](https://code.google.com/p/nsscache), unfortunately it is clear that it was written, designed and tested on/for Linux. Even though NSSCACHE's core is written in Python, not even that will run easily on Solaris 10+.

## nssl2f ##

As a conclusion I decided to write a NSS 'ldap' to 'files (nssl2f) package in Perl (the language which is part of core Solaris). There are a few differences between nssl2f and NSSCACHE.

- nssl2f runs as daemon and syncs (full or incremental) periodically, no need for cron or any other scheduler
- it was designed to work with Solaris 10+, means you don't have to configure LDAP twice (once in the OS once in nssl2f), nssl2f will use the native LDAP OS configuration
- today it supports *passwd*, *group* and *shadow* databases, but it's easily extendable (just let me know if you want me to)


Any questions or comments, please don't hesitate to contact me,

sendai, 2013. <andras.spitzer@ge.com>