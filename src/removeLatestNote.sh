#!/bin/sh

. /mnt/onboard/.adds/nickel-hs/notes/env.sh

showStatus "Deleting Bookmark..."

$SQLITE "$MY_DB" "DELETE FROM Bookmark WHERE ROWID = (SELECT MAX(ROWID) FROM Bookmark);"
