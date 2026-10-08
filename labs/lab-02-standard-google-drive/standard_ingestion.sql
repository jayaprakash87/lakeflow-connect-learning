-- Lab 02 — Standard Google Drive ingestion
--
-- Requirements:
--   Databricks Runtime 17.3+
--   Lakeflow pipeline channel = PREVIEW
--   Existing UC connection: lab_google_drive_connection
--
-- Pipeline configuration:
--   lab.source_url = <Google Drive folder URL>

CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '${lab.source_url}',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
