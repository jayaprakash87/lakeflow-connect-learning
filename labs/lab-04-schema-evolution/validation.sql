-- Lab 04 validation
-- Replace workspace.bronze if your target differs.

DESCRIBE TABLE workspace.bronze.efuse_events_managed;
DESCRIBE TABLE workspace.bronze.efuse_events_standard;

SELECT COUNT(*) AS managed_count
FROM workspace.bronze.efuse_events_managed;

SELECT COUNT(*) AS standard_count
FROM workspace.bronze.efuse_events_standard;

SELECT
  vehicle_id,
  fuse_id,
  temperature_c,
  event_ts
FROM workspace.bronze.efuse_events_managed
ORDER BY event_ts;

SELECT
  vehicle_id,
  fuse_id,
  temperature_c,
  event_ts
FROM workspace.bronze.efuse_events_standard
ORDER BY event_ts;

-- Rescue experiment
SELECT
  vehicle_id,
  fuse_id,
  _rescued_data
FROM workspace.bronze.efuse_events_standard_rescue
WHERE _rescued_data IS NOT NULL;
