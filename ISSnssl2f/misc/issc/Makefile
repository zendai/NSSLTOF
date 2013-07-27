# NSS hook for nss_files.so.1 by sendai 

NSSMODULE=issc
PAMMODULE=pam_$(NSSMODULE)

all: linknssfiles $(NSSMODULE) $(PAMMODULE)


$(NSSMODULE):
	gcc -m32 -o 32/$(NSSMODULE).o -c $(NSSMODULE).c
	gcc -m64 -o 64/$(NSSMODULE).o -c $(NSSMODULE).c
	/usr/ccs/bin/ld -shared 32/$(NSSMODULE).o -lnss_files -o 32/nss_$(NSSMODULE).so.1
	/usr/ccs/bin/ld -shared 64/$(NSSMODULE).o -lnss_files -o 64/nss_$(NSSMODULE).so.1

$(PAMMODULE):
	gcc -m32 -I/usr/include/security $(PAMMODULE).c -c -o 32/$(PAMMODULE).o
	gcc -m64 -I/usr/include/security $(PAMMODULE).c -c -o 64/$(PAMMODULE).o
	/usr/ccs/bin/ld -shared -lpam 32/$(PAMMODULE).o -o 32/$(PAMMODULE).so.1
	/usr/ccs/bin/ld -shared -lpam 64/$(PAMMODULE).o -o 64/$(PAMMODULE).so.1

linknssfiles:
	if [ ! -h /usr/lib/libnss_files.so ]; then ln -s /lib/nss_files.so.1 /usr/lib/libnss_files.so ; fi
	if [ ! -h /usr/lib/64/libnss_files.so ]; then ln -s /lib/64/nss_files.so.1 /usr/lib/64/libnss_files.so ; fi


install: $(NSSMODULE) $(PAMMODULE)
	cp 32/nss_$(NSSMODULE).so.1 /usr/lib
	cp 64/nss_$(NSSMODULE).so.1 /usr/lib/64
	cp 32/$(PAMMODULE).so.1 /usr/lib/security
	cp 64/$(PAMMODULE).so.1 /usr/lib/security/64
	if [ ! -h /usr/lib/security/pam_issc.so ]; then ln -s pam_issc_so.1 /usr/lib/security/pam_issc.so ; fi
	if [ ! -h /usr/lib/security/64/pam_issc.so ]; then ln -s pam_issc_so.1 /usr/lib/security/64/pam_issc.so ; fi
