#!/bin/sh
set -e

. /mnt/onboard/.adds/nickel-hs/notes/env.sh

LOG_ACTION="Text export"
trap logFailure EXIT
logNote "START $LOG_ACTION"

OPENCC_FLAG="/mnt/onboard/.adds/nickel-hs/notes/OPENCC"

showStatus "Processing..."

if [ -f "$TXT" ]; then
    rm -f "$TXT"
    echo "Deleted $TXT"
    logNote "SUCCESS Removed text copy"
    showStatus "Remove Notes from Bookshelf"
else
    if [ ! -f "$EXPORT_NAME" ]; then
        echo "Error: $EXPORT_NAME does not exist." >&2
        exit 1
    fi

    if [ -f "$OPENCC_FLAG" ]; then
        showStatus "Simplified Chinese to Traditional..."
        PYTHONPATH="/mnt/onboard/.adds/nickel-hs/notes/lib${PYTHONPATH:+:$PYTHONPATH}" \
        python - "$EXPORT_NAME" "$TXT" <<'PYTHON'
import os
import sys
from opencc import OpenCC

source_path, output_path = sys.argv[1:3]
with open(source_path, "r", encoding="utf-8") as source:
    text = source.read()

converted = OpenCC("s2t").convert(text)
temporary_path = output_path + ".tmp"
with open(temporary_path, "w", encoding="utf-8") as output:
    output.write(converted)
os.replace(temporary_path, output_path)
print("Converted", source_path, "to", output_path)
PYTHON
        logNote "SUCCESS Text exported with OpenCC s2t"
    else
        cp "$EXPORT_NAME" "$TXT"
        echo "Copied $EXPORT_NAME to $TXT"
        logNote "SUCCESS Text exported without conversion"
    fi
    showStatus "Export Notes to Bookshelf."
fi
