# === dev ===
# FOLDER="."
# EXPORT_FOLDER="."
# === end ===

FOLDER="/mnt/onboard/.adds/nickel-hs"
EXPORT_FOLDER="/mnt/onboard/note"
EXPORT_NAME="$EXPORT_FOLDER/notes.md"
TXT="$EXPORT_FOLDER/筆記.txt"

SQLITE="${FOLDER}/sqlite3"
MY_DB="${FOLDER}/HsKobo.sqlite"

export LD_LIBRARY_PATH="${FOLDER}/lib:${LD_LIBRARY_PATH}"

showStatus() {
    if command -v fbink >/dev/null 2>&1; then
        fbink -qpm -y -2 "$1"
    fi
}
