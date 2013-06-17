
// issc: NSS hooks for <db>.cache files (NSSCACHE 'files' support for Solaris 10+) by sendai 2013.

#include <stdio.h>
#include <nss_common.h>
#include <nss_dbdefs.h>

// For Sparks NSCD compatibility
unsigned int _nss_issc_version = 1;

// Standard nss_files.so.1 definitions
typedef struct files_backend *files_backend_ptr_t;
typedef nss_status_t	(*files_backend_op_t)(files_backend_ptr_t, void *);

typedef uint_t (*files_hash_func)(nss_XbyY_args_t *, int, const char *, int);

typedef struct files_hashent {
	struct files_hashent	*h_first;
	struct files_hashent	*h_next;
	uint_t			h_hash;
} files_hashent_t;

typedef struct {
	char			*l_start;
	int			l_len;
} files_linetab_t;

typedef struct {
	mutex_t		fh_lock;
	int		fh_resultsize;
	int		fh_bufsize;
	int		fh_nhtab;
	files_hash_func	*fh_hash_func;
	int		fh_refcnt;
	int		fh_size;
	timestruc_t	fh_mtime;
	char		*fh_file_start;
	char		*fh_file_end;
	files_linetab_t	*fh_line;
	files_hashent_t	*fh_table;
} files_hash_t;

struct files_backend {
	files_backend_op_t	*ops;
	int			n_ops;
	const char		*filename;
	FILE			*f;
	int			minbuf;
	char			*buf;
	files_hash_t		*hashinfo;
};

extern files_backend_ptr_t _nss_files_passwd_constr();
extern files_backend_ptr_t _nss_files_group_constr();
extern files_backend_ptr_t _nss_files_shadow_constr();

// We'll have hooks for 1. passwd 2. group and 3. shadow

// passwd

nss_backend_t *
_nss_issc_passwd_constr(dummy1,dummy2,dummy3)
	const char *dummy1, *dummy2, *dummy3;
{
	files_backend_ptr_t	be;	
	const char 		*PF_PATH_CACHE="/etc/passwd.cache";

	be = _nss_files_passwd_constr(dummy1, dummy2, dummy3);
	be->filename = PF_PATH_CACHE;

	return((nss_backend_t *)be);
}

// group

nss_backend_t *
_nss_issc_group_constr(dummy1,dummy2,dummy3)
        const char *dummy1, *dummy2, *dummy3;
{
        files_backend_ptr_t     be;
        const char              *GF_PATH_CACHE="/etc/group.cache";

        be = _nss_files_group_constr(dummy1, dummy2, dummy3);
        be->filename = GF_PATH_CACHE;

        return((nss_backend_t *)be);
}

// shadow

nss_backend_t *
_nss_issc_shadow_constr(dummy1,dummy2,dummy3)
        const char *dummy1, *dummy2, *dummy3;
{
        files_backend_ptr_t     be;
        const char              *SHADOW_CACHE="/etc/shadow.cache";

        be = _nss_files_shadow_constr(dummy1, dummy2, dummy3);
        be->filename = SHADOW_CACHE;

        return((nss_backend_t *)be);
}
