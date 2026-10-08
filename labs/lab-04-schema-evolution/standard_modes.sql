-- Lab 04 — Standard Google Drive schema evolution variants
-- Assumes pipeline parameter:
--   source_url = <Google Drive folder URL>
-- and default catalog/schema already configured.

-- A. Default inferred-schema behavior
CREATE OR REFRESH STREAMING TABLE efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);

-- B. Strict contract: fail when a new source column appears
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_strict
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  schemaEvolutionMode => 'failOnNewColumns',
  `databricks.connection` => 'lab_google_drive_connection'
);

-- C. Rescue unexpected fields instead of evolving the schema
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_rescue
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  schemaEvolutionMode => 'rescue',
  rescuedDataColumn => '_rescued_data',
  `databricks.connection` => 'lab_google_drive_connection'
);

-- D. Add columns and automatically widen supported types
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_widen
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  schemaEvolutionMode => 'addNewColumnsWithTypeWidening',
  `databricks.connection` => 'lab_google_drive_connection'
);
