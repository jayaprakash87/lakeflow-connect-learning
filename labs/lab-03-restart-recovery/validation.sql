-- Lab 03 validation queries
-- Replace workspace.bronze if your Lab 01/02 destination differs.

-- Managed row count
SELECT COUNT(*) AS managed_count
FROM workspace.bronze.efuse_events_managed;

-- Standard row count
SELECT COUNT(*) AS standard_count
FROM workspace.bronze.efuse_events_standard;

-- Inspect managed rows
SELECT *
FROM workspace.bronze.efuse_events_managed
ORDER BY event_ts;

-- Inspect standard rows
SELECT *
FROM workspace.bronze.efuse_events_standard
ORDER BY event_ts;

-- Optional duplicate check based on the synthetic event identity.
SELECT
  vehicle_id,
  fuse_id,
  event_ts,
  COUNT(*) AS copies
FROM workspace.bronze.efuse_events_managed
GROUP BY vehicle_id, fuse_id, event_ts
HAVING COUNT(*) > 1;

SELECT
  vehicle_id,
  fuse_id,
  event_ts,
  COUNT(*) AS copies
FROM workspace.bronze.efuse_events_standard
GROUP BY vehicle_id, fuse_id, event_ts
HAVING COUNT(*) > 1;
