-- Lab 01 validation queries

-- 1. Verify that the target exists and inspect the ingested rows.
SELECT *
FROM bronze.efuse_events_managed
LIMIT 20;

-- 2. Count ingested records.
SELECT COUNT(*) AS record_count
FROM bronze.efuse_events_managed;

-- 3. If the connector has been configured to expose Kafka source metadata,
-- inspect topic, partition, offset, and timestamp fields here.
-- Adjust the column name to the source metadata struct configured in the lab.
--
-- SELECT
--   <metadata_column>.topic,
--   <metadata_column>.partition,
--   <metadata_column>.offset,
--   <metadata_column>.timestamp
-- FROM bronze.efuse_events_managed
-- ORDER BY <metadata_column>.partition, <metadata_column>.offset;

-- 4. After Lab 04 adds temperature_c, inspect the destination schema.
DESCRIBE TABLE bronze.efuse_events_managed;
