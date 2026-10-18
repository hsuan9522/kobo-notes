#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUTPUT_DIR="$PROJECT_DIR/dist"
STAGING_DIR=$(mktemp -d)
PACKAGE_VERSION=${PACKAGE_VERSION:-$(git -C "$PROJECT_DIR" describe --tags --exact-match 2>/dev/null || printf 'dev')}

if [ -z "${BACKUP_SOURCE:-}" ]; then
    if [ -d "$PROJECT_DIR/vendor/hs-kobo-backup" ]; then
        BACKUP_SOURCE="$PROJECT_DIR/vendor/hs-kobo-backup"
    else
        BACKUP_SOURCE="$PROJECT_DIR/../hs-kobo-backup"
    fi
fi
if [ -z "${BACKUP_VERSION:-}" ]; then
    BACKUP_VERSION=$(git -C "$BACKUP_SOURCE" describe --tags --exact-match 2>/dev/null || tr -d '[:space:]' < "$PROJECT_DIR/HS_KOBO_BACKUP_VERSION")
fi

cleanup() {
    rm -rf "$STAGING_DIR"
}
trap cleanup EXIT INT TERM

ONBOARD_DIR="$STAGING_DIR/mnt/onboard"
NM_DIR="$ONBOARD_DIR/.adds/nm"
NICKEL_HS_DIR="$ONBOARD_DIR/.adds/nickel-hs"
BACKUP_DIR="$NICKEL_HS_DIR/backup"
NOTES_DIR="$NICKEL_HS_DIR/notes"

if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "找不到 hs-kobo-backup：$BACKUP_SOURCE" >&2
    exit 1
fi
if [ ! -f "$BACKUP_SOURCE/vendor/lib/libsqlite3.so.0" ]; then
    echo "找不到 SQLite runtime library：$BACKUP_SOURCE/vendor/lib/libsqlite3.so.0" >&2
    exit 1
fi

mkdir -p "$NM_DIR" "$BACKUP_DIR" "$NOTES_DIR" "$OUTPUT_DIR"
printf '%s\n' "$BACKUP_VERSION" > "$BACKUP_DIR/VERSION"
printf '%s\n' "$PACKAGE_VERSION" > "$NOTES_DIR/VERSION"

# NickelMenu configuration and Notes commands.
cp -p "$PROJECT_DIR/src/hsNotes" "$NM_DIR/hsNotes"
cp -p "$PROJECT_DIR/src/env.sh" "$NOTES_DIR/"
cp -p "$PROJECT_DIR/src/dbToMarkdown.sh" "$NOTES_DIR/"
cp -p "$PROJECT_DIR/src/markdownToTxt.sh" "$NOTES_DIR/"
cp -p "$PROJECT_DIR/src/removeLatestNote.sh" "$NOTES_DIR/"
cp -p "$PROJECT_DIR/src/show4LatestNotes.sh" "$NOTES_DIR/"

# Notes uses the shared backup database and bookmark sync command.
cp -p "$BACKUP_SOURCE/assets/HsKobo.sqlite.template" "$NICKEL_HS_DIR/"
cp -p "$BACKUP_SOURCE/vendor/sqlite3" "$NICKEL_HS_DIR/"
cp -R "$BACKUP_SOURCE/vendor/lib" "$NICKEL_HS_DIR/"
cp -p "$BACKUP_SOURCE/src/env.sh" "$BACKUP_DIR/"
cp -p "$BACKUP_SOURCE/src/syncBookmarks.sh" "$BACKUP_DIR/"

chmod +x "$NM_DIR/hsNotes"
chmod +x "$NOTES_DIR/dbToMarkdown.sh"
chmod +x "$NOTES_DIR/markdownToTxt.sh"
chmod +x "$NOTES_DIR/removeLatestNote.sh"
chmod +x "$NOTES_DIR/show4LatestNotes.sh"
chmod +x "$NICKEL_HS_DIR/sqlite3"
chmod +x "$BACKUP_DIR/syncBookmarks.sh"
chmod 755 "$NICKEL_HS_DIR/lib/libsqlite3.so.0"

find "$STAGING_DIR" -name ".DS_Store" -delete

OUTPUT_FILE="$OUTPUT_DIR/KoboRoot.tgz"
rm -f "$OUTPUT_FILE"
tar -C "$STAGING_DIR" -czf "$OUTPUT_FILE" mnt

echo "打包完成：$OUTPUT_FILE"
