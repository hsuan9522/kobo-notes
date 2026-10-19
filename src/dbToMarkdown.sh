#!/bin/sh
set -eu

# === dev ===
# . ./env.sh
# === end ===


. /mnt/onboard/.adds/nickel-hs/notes/env.sh

LOG_ACTION="Markdown export"
trap logFailure EXIT
logNote "START $LOG_ACTION"

showStatus "Writing to Markdown..."

echo "# Kobo Notes" > "$EXPORT_NAME"


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
    -- 當 b.dateCreated 轉為 YYYY-MM-DD 且與前一條不同時，顯示日期
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

if $SQLITE "$MY_DB" "$SQL" >> "$EXPORT_NAME"; then
    logNote "SUCCESS $LOG_ACTION"
else
    logNote "ERROR $LOG_ACTION sqlite failed"
    exit 1
fi
