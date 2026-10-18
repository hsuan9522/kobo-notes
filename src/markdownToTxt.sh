#!/bin/sh

. /mnt/onboard/.adds/nickel-hs/notes/env.sh


showStatus "Converting Markdown to TXT..."

if [ -f "$TXT" ]; then
    rm "$TXT" && echo "Deleted $TXT"
else
    if [ -f "$EXPORT_NAME" ]; then
        cp "$EXPORT_NAME" "$TXT" && echo "Copied $EXPORT_NAME to $TXT"
    else
        echo "Error: $EXPORT_NAME does not exist."
    fi
fi
