-- Lab 02 — Standard Google Drive ingestion
--
-- Pipeline prerequisites:
--   1. ETL pipeline
--   2. Default catalog/schema already selected
--   3. Channel = PREVIEW
--   4. Existing UC connection = lab_google_drive_connection
--   5. Pipeline parameter:
--        source_url = <Google Drive folder URL>

CREATE OR REFRESH STREAMING TABLE efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);

-- If Pipeline Parameters are unavailable in the workspace, use a pipeline
-- Configuration entry instead:
--
--   lab.source_url = <Google Drive folder URL>
--
-- and replace :source_url above with:
--
--   '${lab.source_url}'
