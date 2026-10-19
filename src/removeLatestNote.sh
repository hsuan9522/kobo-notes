#!/bin/sh

. /mnt/onboard/.adds/nickel-hs/notes/env.sh

LOG_ACTION="Delete latest bookmark"
trap logFailure EXIT
logNote "START $LOG_ACTION"

showStatus "Deleting Bookmark..."

if $SQLITE "$MY_DB" "DELETE FROM Bookmark WHERE ROWID = (SELECT MAX(ROWID) FROM Bookmark);"; then
    logNote "SUCCESS $LOG_ACTION"
else
    logNote "ERROR $LOG_ACTION sqlite failed"
    exit 1
fi
