#!/bin/sh

. /mnt/onboard/.adds/nickel-hs/notes/env.sh

showStatus "Processing..."

if [ -f "$TXT" ]; then
    rm "$TXT" && echo "Deleted $TXT"
    showStatus "Remove Notes from Bookshelf"
else
    if [ -f "$EXPORT_NAME" ]; then
        cp "$EXPORT_NAME" "$TXT" && echo "Copied $EXPORT_NAME to $TXT"
        showStatus "Export Notes to Bookshelf."
    else
        echo "Error: $EXPORT_NAME does not exist."
    fi
fi
