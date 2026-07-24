#!/bin/sh

source ./config.sh

FOLDER="/mnt/onboard/.adds/utils"
DB="/mnt/onboard/.kobo/KoboReader.sqlite"
SQLITE="${FOLDER}/sqlite3"
MY_DB="${FOLDER}/HsKobo.sqlite"

LD_LIBRARY_PATH="${FOLDER}/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH


echo "# Kobo Notes" > $EXPORT_NAME


has_data=$($SQLITE "$MY_DB" "SELECT 1 FROM Bookmark LIMIT 1;") 

if [ -z "$has_data" ]; then
    # B 資料庫的 Bookmark 表沒有資料，將從 A 資料庫複製所有記錄...

    $SQLITE "$DB" <<EOF > /tmp/bookmark_with_title.sql
.mode insert Bookmark
SELECT b.*, c.Title as title
FROM Bookmark b
LEFT JOIN content c ON b.VolumeID = c.ContentID;
EOF
    
    # 將數據導入 B
    $SQLITE "$MY_DB" ".read /tmp/bookmark_with_title.sql"
    rm /tmp/bookmark_with_title.sql
    
else
    # B 資料庫的 Bookmark 表有資料，正在比對差異...

    $SQLITE "$MY_DB" <<EOF
ATTACH DATABASE '$DB' AS db_a;

-- 確保添加了BEGIN和COMMIT事務語句
BEGIN;

-- 先刪除已有的表以避免衝突
DROP TABLE IF EXISTS missing_records;

-- 建立持久表存儲差異記錄
CREATE TABLE missing_records AS
SELECT b.*, c.Title as title
FROM db_a.Bookmark b
LEFT JOIN db_a.content c ON b.VolumeID = c.ContentID
WHERE NOT EXISTS (
    SELECT 1 FROM Bookmark 
    WHERE Bookmark.BookmarkID = b.BookmarkID 
);

COMMIT;
EOF
    
    diff_count=$($SQLITE "$MY_DB" "SELECT COUNT(*) FROM missing_records;")
    
    if [ "$diff_count" -gt 0 ]; then
        echo "發現 $diff_count 條記錄在 A 中存在但不在 B 中，正在複製..."
    
        # 將差異記錄插入到 B 資料庫
        $SQLITE "$MY_DB" "INSERT INTO Bookmark SELECT * FROM missing_records";
    
    else
        echo "沒有發現需要同步的記錄。"
    fi
fi

# 顯示
SQL="WITH LatestBookmarks AS (
  SELECT 
    VolumeID,
    MAX(dateCreated) AS latest_date
  FROM Bookmark
  WHERE Type = 'highlight' OR Type = 'note'
  GROUP BY VolumeID
)

SELECT 
  CASE 
    -- 當這是該書（title）的第一筆記錄，才顯示 title
    WHEN NOT EXISTS (
      SELECT 1 
      FROM Bookmark prev 
      WHERE prev.VolumeID = b.VolumeID 
        AND prev.dateCreated < b.dateCreated
        AND prev.Type != 'dogear'
    ) THEN char(10) || '### ' || b.title || char(10)
    ELSE ''
  END ||

  CASE 
    -- 當 `b.dateCreated` 轉為 `YYYY-MM-DD` 且與前一條不同時，顯示日期
    WHEN NOT EXISTS (
      SELECT 1 FROM Bookmark prev 
      WHERE prev.VolumeID = b.VolumeID 
        AND prev.dateCreated < b.dateCreated
        AND date(prev.dateCreated) = date(b.dateCreated)
        AND prev.Type != 'dogear'
    ) THEN char(10) || date(b.dateCreated) || char(10)
    ELSE ''
  END ||

  '- ' || b.Text || 

  -- 顯示 Annotation
  CASE
    WHEN b.Annotation IS NOT NULL AND b.Annotation != '' THEN char(10) || '> ' || b.Annotation
    ELSE ''
  END AS formatted_output

FROM Bookmark b
JOIN LatestBookmarks lb ON b.VolumeID = lb.VolumeID
WHERE b.Type = 'highlight' OR b.Type = 'note'
ORDER BY lb.latest_date DESC, b.title, b.dateCreated;"

$SQLITE "$MY_DB" "$SQL" >> $EXPORT_NAME
