# NSS hook for nss_files.so.1 by sendai 

NSSMODULE=issc

all: linknssfiles $(NSSMODULE)


$(NSSMODULE):
	gcc -o $(NSSMODULE).o -c $(NSSMODULE).c
	/usr/ccs/bin/ld -shared $(NSSMODULE).o -lnss_files -o nss_$(NSSMODULE).so.1

linknssfiles:
	if [ ! -h /usr/lib/libnss_files.so ]; then ln -s /lib/nss_files.so.1 /usr/lib/libnss_files.so ; fi

install: $(NSSMODULE)
	cp nss_$(NSSMODULE).so.1 /usr/lib
