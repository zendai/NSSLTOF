## NSSLTOF, The NSSCACHE for Solaris 10+ ##

**NSSLTOF** intends to ease the NSS initiated LDAP load on Solaris 10+ hosts 
by providing two layers (the sync layer and the nss layer) as a replacement. 
If you ever had to face problems with the 'ldap' module in nsswitch.conf, 
you may have wondered if there is a chance to cache LDAP results locally on 
the server.

## The motivation ##

Well, that's what NSCD is for you might say, and partly you are correct. In 
theory NSCD *should* efficiently cache the results from any NSS2 compliant 
source backend in nsswitch but in real life this is *unfortunately not 
fully true*, because 

- NSCD can and eventually will crash
- probably you have a 3rd party NSS backend which is not NSS2 compatible (like 
  Likewise's 'lsass' module) meaning NSCD will reject caching
- even if none of the previous ones are affecting you, still there are a few NSS 
  library calls which are simply not cached/supported by NSCD, like 
  _getgroupsbymember(). 

## Inspired by NSSCACHE ##

We are not the first one to realize this issue, Google came to the same conclusion, 
that's why they came up with [NSSCACHE](https://code.google.com/p/nsscache), 
unfortunately it is clear that it was written, designed and tested on/for Linux. 
Even though NSSCACHE's core is written in Python, not even that will run easily on 
Solaris 10+.

## NSSLTOF ##

As a conclusion I decided to write a NSS 'ldap' to 'files (nssl2f) package in Perl 
(the language which is part of core Solaris). There are a few differences between 
nssl2f and NSSCACHE.

- nssl2f runs as daemon and syncs (full or incremental) periodically, no need for 
  cron or any other scheduler
- it was designed to work with Solaris 10+, means you don't have to configure LDAP 
  twice (once in the OS once in nssl2f), nssl2f will use the native LDAP OS 
  configuration
- today it supports *passwd*, *group* and *shadow* databases, but it's easily 
  extendable (just let me know if you want me to)
  
## Known issues ##

NSS part works fine on all Solaris 10 versions, unfortunately though one of the PAM 
modules (pam_unix_auth.so.1) may surprise you if you are using Solaris 10u5 
(<= Generic 127XXX-XX) or earlier. Let me describe the two behaviour of 
pam_unix_auth.so.1 :

**before and at Solaris 10u5** :
 - they used implicit condition : "if the user's repository backend *is* LDAP, return 
 with PAM_IGNORE, otherwise authenticate"
  
**after Solaris 10u5** :
 - they used excplicit condition : "if the user's repository backend *is not* files, 
 nis or nisplus, return PAM_IGNORE, otherwise authenticate"
  
 
The **second**, newer one is the right way to do it, because it will only authenticate 
against the *files*, *nis*, *nisplus* backends, anything else (including issc and 
any other 3rd party nss backends) will be ignored (PAM_IGNORE).

The **first**, older one will ignore only *ldap*, and will authenticate agaisnt anything 
else. Not so 3rd party-friendly, so it will authenticate against issc as well. The best 
way to handle that is that in case the user is indeed in the issc database will return 
a never matching password, so pam_unix_auth.so.1 will retutn "Authentication failed". 
This is not a big deal since most likely you'll have the real authentication for the 
user (via PAM ldap or PAM radius), but then it's important to choose the right control 
flag for pam_unix_auth.so.1.

Let's take an example :

`login auth binding    pam_unix_auth.so.1 server_policy`

`login auth sufficient pam_ldap.so.1`

We assume the user is trying to log in is in issc, and authenticates via LDAP. 

1. If we have **Solaris 10u6+**, it's simple, pam_unix_auth.so.1 will return 
PAM_IGNORE as I explained before, and pam_ldap.so.1 can decide the fate of the user 
logging in.

2. If we have **Solaris 10u5 and earlier**, pam_unix_auth.so.1 will return "Authentication 
failure", and because the control flag is *binding*, it doesn't matter if pam_ldap.so.1 
will return with (Authentication) "Success", the overall result will be "Authentication 
failure". In this case the solution is to set *binding* to sufficient, which will make 
this scenario work.


Any questions or comments, please don't hesitate to contact me,

sendai, 2013. <andras.spitzer@ge.com>