#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
TMPFILE=/tmp/pam.conf_temp

if [ -f $TMPFILE ]; then rm $TMPFILE ; fi
cp /etc/pam.conf /etc/pam.conf_PRENSSLTOFPAM

if [ `egrep -c "pam_issc.so" /etc/pam.conf` -eq 0 ];
then
        echo "PAM module issc is not configured, exiting.."
        exit 0
fi

egrep -v "pam_issc.so" /etc/pam.conf >$TMPFILE

if [ `diff /etc/pam.conf $TMPFILE | wc -l` -eq 2 ];
then
        mv $TMPFILE /etc/pam.conf
else
        echo "Unexpected output, skipping change."
fi

exit 0

