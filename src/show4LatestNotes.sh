#!/bin/sh

. /mnt/onboard/.adds/nickel-hs/notes/env.sh

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
