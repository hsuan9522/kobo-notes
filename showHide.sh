#!/bin/sh

NOTE_FOLDER="/mnt/onboard/note"
TXT="$NOTE_FOLDER/筆記.txt"
NOTE="$NOTE_FOLDER/notes.md"

if [ -f "$TXT" ]; then
    rm "$TXT" && echo "Deleted $TXT"
else
    if [ -f "$NOTE" ]; then
        cp "$NOTE" "$TXT" && echo "Copied $NOTE to $TXT"
    else
        echo "Error: $NOTE does not exist."
    fi
fi
