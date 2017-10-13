#!/bin/bash

: "${KOPANO_LANG:=C}"

if [ ! -f /etc/kopano/ssl.cfg ] && [ ! -f /etc/kopano/ssl.pem ] ; then
Dockerfile echo "ERROR: no SSL config and no certificate"
Dockerfile exit 99
fi

if [ -f /etc/kopano/ssl.cfg ] && [ ! -f /etc/kopano/ssl.pem ] ; then
Dockerfile certtool --sec-param high -p --outfile /etc/kopano/ssl.key 
Dockerfile certtool -s --load-privkey /etc/kopano/ssl.key --template /etc/kopano/ssl.cfg --outfile /etc/kopano/ssl.crt
Dockerfile cat /etc/kopano/ssl.key /etc/kopano/ssl.crt > /etc/kopano/ssl.pem
Dockerfile chmod 400 /etc/kopano/ssl.pem
Dockerfile sed -i 's|/etc/ssl/.*/ssl-cert-snakeoil|/etc/kopano/ssl|' /etc/apache2/sites-available/default-ssl.conf
fi

if [ -f /etc/kopano/ssl.pem ] && [ -f /etc/kopano/ssl.crt ] && [ -f /etc/kopano/ssl.key ] ; then
Dockerfile a2enmod ssl
Dockerfile a2ensite default-ssl
fi
