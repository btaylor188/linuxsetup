#!/bin/bash
SRCDIR="/opt/docker"
DESTDIR="/mnt/Storage/Backup/Docker/Sovereign"
TIME=`date +%Y-%m-%d`
#FILENAME=Sovereign-$TIME.tar.gz
#tar -cpzf $DESTDIR/$FILENAME $SRCDIR
FILENAME=Sovereign-$TIME.zip
zip -r  $DESTDIR/$FILENAME $SRCDIR
find $DESTDIR/*.zip -mtime +20  -type f -delete

