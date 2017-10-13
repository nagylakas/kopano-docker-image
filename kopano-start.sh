#!/bin/bash

: "${KOPANO_LANG:=C}"
echo LANG=\"$KOPANO_LANG\" > /etc/default/locale
sed -i 's|KOPANO_LOCALE="C"|KOPANO_LOCALE="'$KOPANO_LANG'"|; s|KOPANO_USERSCRIPT_LOCALE="C"|KOPANO_USERSCRIPT_LOCALE="'$KOPANO_LANG'"|' /etc/default/kopano
sed -i 's|^#. /etc/default/locale|. /etc/default/locale|' /etc/apache2/envvars
export KOPANO_LOCALE=$KOPANO_LANG
export KOPANO_USERSCRIPT_LOCALE=$KOPANO_LANG

mkdir -p /var/run/kopano && chown kopano:kopano /var/run/kopano
mkdir -p /run/lock/apache2 && mkdir -p /run/apache2
mkdir -p /run/sshd

/usr/local/bin/kopano-init.sh

if [ -e /etc/kopano/ssh_authorized_keys ] ; then
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat /etc/kopano/ssh_authorized_keys > /root/.ssh/authorized_keys
fi

exec /usr/bin/supervisord
