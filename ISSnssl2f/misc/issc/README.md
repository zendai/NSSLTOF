##NSS cache module for NSSLTOF##

### Why NSSCACHE won't run on Solaris 10+ ###

This module is part of the **NSSLTOF** package.

[NSSCACHE](https://code.google.com/p/nsscache) is a tool 
to provide a clean workaround to the problems around using LDAP as an NSS
provider, broken NSCD implementations, bugs, core dumps, uncached
library calls (_getgroupsbymember() for example on Solaris).

The operation of NSSCACHE can be divided into two parts. First part is
to sync a NSS database from LDAP to a local file(s) which can be either
in 1. files format or in 2. Berkeley DB. The second part is when you
configure /etc/nsswitch.conf to use those local files. On Linux the 2.
is nativaly supported by nss_db, and 1. is supported by a library
called nss-cache and which is part of the NSSCACHE package.

On Solaris 10+ the first part works since it is written in Python, so
you can sync LDAP into local files on Solaris too. The second step
though is problem with Solaris 10+. Solaris does not have support for
Bekeley DBs, neither nss-cache compile succesfully. So the base
NSSCACHE package can't be used on Solaris, at least not without a lot
effort which makes it unfeasible for mass deployment at a large organization.

This package intend to provide a module for the second part, the
/etc/nsswitch.conf part. If you configure the first part to use
*files*, which will create files under /etc named <db>.cache, for
example /etc/passwd.cache, you have to compile and insall issc and just
add the keyword *issc* into your /etc/nswitch.conf and you are done!

issc is a simple wrapper using the original nss_files.so.1, catching
the original constructors and modifies the filename by appending
'.cache' to it's end. It is also compatible with the Solaris 10+ NSCD
Sparks requirement since it has the _nss_issc_version global symbol
defined, so even though issc is a foreign source backend, NSCD will not
reject it.


Supported databases : passwd, group, shadow

sendai, 2013.
