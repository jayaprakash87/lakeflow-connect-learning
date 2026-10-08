-- Lab 02: standard Google Drive connector
-- Requirements:
--   Databricks Runtime 17.3+
--   Lakeflow pipeline channel = PREVIEW
-- Replace the source URL if you are not parameterizing it.

CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '<GOOGLE_DRIVE_FOLDER_URL>',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
