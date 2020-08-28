#!/bin/bash

LOGROTATE=yes
INIT_SCRIPT=yes
INIT_SCRIPT_AUTO_START=yes
NAME_LOWER=gpiofands18b20


if [ "$UID" -ne "0" ]
then
  echo "run as root... usage: sudo $0"
  barf
fi

function transmogrify { 
    if [ -z "$1" ]
        then barf "usage: transmogrify FROM TO"
    fi
    if [ -z "$2" ]
        then barf "usage: transmogrify FROM TO"
    fi
    cat "$1" | sed -e "s:NAME_LOWER:$NAME_LOWER:g" | sed -e "s:NAME:$NAME:g" -e "s:PYTHON:$PYTHON:g" > "$2"
}

function barf {
    echo $@
    exit 1
} 

if [ ! -z "$LOGROTATE" ] 
then
transmogrify logrotate.conf /etc/logrotate.d/$NAME_LOWER
echo "installed: /etc/logrotate.d/$NAME_LOWER"
fi

if [ ! -z "$INIT_SCRIPT" ] 
then
transmogrify initd-template /etc/init.d/$NAME_LOWER
chmod 755 /etc/init.d/$NAME_LOWER
echo "installed: /etc/init.d/$NAME_LOWER"
fi

if [ ! -z "$INIT_SCRIPT_AUTO_START" ] 
then
update-rc.d $NAME_LOWER defaults
echo "enabled auto start via /etc/rcX.d"
echo "starting: /etc/init.d/$NAME_LOWER start"
/etc/init.d/$NAME_LOWER start
fi
