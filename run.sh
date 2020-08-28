#!/bin/bash
cd "`dirname $0`"
set -o allexport

OURPATH="`dirname $0`"
set +o allexport
SCRIPT="$OURPATH/GPIOFanDS18B20.py"
ARGS=" "
COUNTER=1
PYTHON=python3

trap "echo exiting...;sleep 3; exit 1" SIGTERM SIGINT SIGHUP EXIT

# sudo i2cset -y -f 0 0x34 0x30 0x23
cd `dirname $SCRIPT`
echo "starting `basename $SCRIPT` $ARGS:"
ls -l $SCRIPT
while sleep 1
do nice --3 $PYTHON -u $SCRIPT $ARGS
echo Exited $?... exit number $COUNTER
let "COUNTER++"
done
