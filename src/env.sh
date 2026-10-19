# === dev ===
# FOLDER="."
# EXPORT_FOLDER="."
# === end ===

FOLDER="/mnt/onboard/.adds/nickel-hs"
LOG_DIR="${FOLDER}/logs"
LOG_FILE="${LOG_DIR}/notes.log"
EXPORT_FOLDER="/mnt/onboard/note"
EXPORT_NAME="$EXPORT_FOLDER/notes.md"
TXT="$EXPORT_FOLDER/筆記.txt"

SQLITE="${FOLDER}/sqlite3"
MY_DB="${FOLDER}/HsKobo.sqlite"

export LD_LIBRARY_PATH="${FOLDER}/lib:${LD_LIBRARY_PATH:-}"

logNote() {
    mkdir -p "$LOG_DIR"
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

logFailure() {
    status=$?
    if [ "$status" -ne 0 ]; then
        logNote "ERROR ${LOG_ACTION:-kobo-notes} exit=$status"
    fi
}

showStatus() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -qpm -y -2 "$1"
    fi
}
