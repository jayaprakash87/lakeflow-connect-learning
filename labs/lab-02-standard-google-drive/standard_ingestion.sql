-- Lab 02: standard Google Drive connector
-- Replace the source URL and connection name before execution.

CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '<GOOGLE_DRIVE_FOLDER_URL>',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
