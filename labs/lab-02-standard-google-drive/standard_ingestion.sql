-- Lab 02: standard Google Drive connector
-- Requirements:
--   Databricks Runtime 17.3+
--   Lakeflow pipeline channel = PREVIEW
--
-- This source URL is configurable. In the pipeline settings, add:
--
--   Key:   lab.source_url
--   Value: https://drive.google.com/drive/u/0/folders/...
--
-- Then the SQL below reads that pipeline configuration value.

CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '${lab.source_url}',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
