-- Lab 07 — Standard Kafka validation
-- Replace main.bronze if your target differs.

SELECT *
FROM main.bronze.efuse_events_standard
LIMIT 20;

SELECT COUNT(*) AS record_count
FROM main.bronze.efuse_events_standard;

SELECT
  _kafka_metadata.partition,
  MIN(_kafka_metadata.offset) AS min_offset,
  MAX(_kafka_metadata.offset) AS max_offset,
  COUNT(*) AS records
FROM main.bronze.efuse_events_standard
GROUP BY _kafka_metadata.partition
ORDER BY _kafka_metadata.partition;

SELECT
  CAST(key AS STRING) AS message_key,
  CAST(value AS STRING) AS json_payload,
  _kafka_metadata.topic,
  _kafka_metadata.partition,
  _kafka_metadata.offset,
  _kafka_metadata.timestamp
FROM main.bronze.efuse_events_standard
ORDER BY
  _kafka_metadata.partition,
  _kafka_metadata.offset;

SELECT
  CAST(value AS STRING):vehicle_id::STRING AS vehicle_id,
  CAST(value AS STRING):fuse_id::STRING AS fuse_id,
  CAST(value AS STRING):current_a::DOUBLE AS current_a,
  CAST(value AS STRING):voltage_v::DOUBLE AS voltage_v,
  CAST(value AS STRING):switch_state::INT AS switch_state,
  CAST(value AS STRING):event_ts::TIMESTAMP AS event_ts,
  _kafka_metadata.partition AS kafka_partition,
  _kafka_metadata.offset AS kafka_offset
FROM main.bronze.efuse_events_standard
ORDER BY kafka_partition, kafka_offset;

DESCRIBE TABLE main.bronze.efuse_events_standard;
