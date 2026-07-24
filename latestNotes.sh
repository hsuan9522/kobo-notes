#!/bin/sh

FOLDER="/mnt/onboard/.adds/utils"
EXPORT="$EXPORT_FOLDER/notes.md"

SQLITE="${FOLDER}/sqlite3"
MY_DB="${FOLDER}/notes/Bookmark.sqlite"

LD_LIBRARY_PATH="${FOLDER}/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH

# 查詢最新的四筆高亮資料並格式化輸出
data=$($SQLITE "$MY_DB" <<EOF
SELECT 
    b.title || ', ' || date(b.dateCreated) || char(10, 10) ||
    '- ' || b.Text || char(10) || ' ' AS formatted_output
FROM Bookmark b
WHERE b.Type = 'highlight'
ORDER BY b.dateCreated DESC
LIMIT 4;
EOF
)

# 輸出結果
echo "$data"
