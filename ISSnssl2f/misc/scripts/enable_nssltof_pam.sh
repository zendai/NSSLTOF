#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
TMPFILE=/tmp/pam.conf_temp

if [ -f $TMPFILE ]; then rm $TMPFILE ; fi
cp /etc/pam.conf /etc/pam.conf_PRENSSLTOFPAM

if [ `egrep -c "pam_issc.so" /etc/pam.conf` -ne 0 ];
then
	echo "PAM module issc already configured, exiting.."
	exit 0
fi

while read line
do
	if [ `echo "$line" | grep -c '^[^#]*passwd.*auth.*pam_passwd_auth.so.*'` -eq 1 ];
	then
	  echo "passwd	auth requisite		pam_issc.so.1" >>$TMPFILE
	fi
	echo "$line" >>$TMPFILE

done < /etc/pam.conf

if [ `diff /etc/pam.conf $TMPFILE | wc -l` -eq 2 ];
then
	mv $TMPFILE /etc/pam.conf
else
	echo "Unexpected output, skipping change."
fi

exit 0
