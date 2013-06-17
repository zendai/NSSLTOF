# NSS hook for nss_files.so.1 by sendai 

NSSMODULE=issc

all: linknssfiles $(NSSMODULE)


$(NSSMODULE):
	gcc -m32 -o 32/$(NSSMODULE).o -c $(NSSMODULE).c
	gcc -m64 -o 64/$(NSSMODULE).o -c $(NSSMODULE).c
	/usr/ccs/bin/ld -shared 32/$(NSSMODULE).o -lnss_files -o 32/nss_$(NSSMODULE).so.1
	/usr/ccs/bin/ld -shared 64/$(NSSMODULE).o -lnss_files -o 64/nss_$(NSSMODULE).so.1

linknssfiles:
	if [ ! -h /usr/lib/libnss_files.so ]; then ln -s /lib/nss_files.so.1 /usr/lib/libnss_files.so ; fi
	if [ ! -h /usr/lib/64/libnss_files.so ]; then ln -s /lib/64/nss_files.so.1 /usr/lib/64/libnss_files.so ; fi

install: $(NSSMODULE)
	cp 32/nss_$(NSSMODULE).so.1 /usr/lib
	cp 64/nss_$(NSSMODULE).so.1 /usr/lib/64
