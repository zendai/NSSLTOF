/* 
  PAM module for the NSSLTOF package. Under normal circumstances an NSS package should not have
  a PAM module, but in Solaris if you are using a 3rd party NSS module (Solaris has an internal
  list of known NSS modules, like 'files', 'ldap', etc.) password change will fail. The reason
  because passwd will scan nsswitch.conf and quit as it finds an unkown module. The solution is
  to set the default PAM repository before pam_passwd_auth.so.1, so it doesn't have to scan
  the nsswitch.conf. In short, just place it before pam_passwd_auth.so.1.


-------------------------

Before in /etc/pam.conf :

#
# passwd command (explicit because of a different authentication module)
#
passwd  auth required           pam_passwd_auth.so.1

In which case you'll see this if you try changing a local password :

root@isslabsol03 #passwd sendai
passwd: Unsupported nsswitch entry for "passwd:". Use "-r repository ".
Unexpected failure. Password file/table unchanged.

A workaround to this is to specify the repository :

root@isslabsol03 #passwd -r files sendai
New Password: 
Re-enter new Password: 
passwd: password successfully changed for sendai

-------------------------

After :

#
# passwd command (explicit because of a different authentication module)
#
passwd  auth requisite          pam_issc.so.1
passwd  auth required           pam_passwd_auth.so.1

In which case password change will work as without NSSLTOF :

root@isslabsol03 #passwd sendai
New Password: 
Re-enter new Password: 
passwd: password successfully changed for sendai

*/


#include <pam_appl.h>
#include <syslog.h>

void issc_log(int priority, const char *msg)
{
	openlog("issc_pam", LOG_PID, LOG_AUTH);
	syslog(priority, msg);
	closelog();
}

int pam_sm_authenticate(pam_handle_t *pamh, int flgas, int argc, const char **argv)
{
	int res;
	pam_repository_t *auth_rep = NULL;
	pam_repository_t files_rep;

	res = pam_get_item(pamh, PAM_REPOSITORY, (void **)&auth_rep);
	if (res != PAM_SUCCESS)
	{
	  issc_log(LOG_ERR, "pam_issc: pam_sm_authenticate: error getting repository");
	  return(PAM_SYSTEM_ERR);
	}

	if (auth_rep == NULL)
	{
	  files_rep.type = "files";
  	  files_rep.scope = NULL;
	  files_rep.scope_len = 0;

	  (void) pam_set_item(pamh, PAM_REPOSITORY, (void *) &files_rep);
	  issc_log(LOG_INFO, "pam_issc: default repository set to files");
	}

	return(PAM_IGNORE);
}
