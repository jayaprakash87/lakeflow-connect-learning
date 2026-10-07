-- Lab 01 validation queries
-- Lab 01 intentionally keeps Kafka key/value raw so that we isolate
-- ingestion mechanics from business parsing.

SELECT *
FROM bronze.efuse_events_managed
LIMIT 20;

SELECT COUNT(*) AS record_count
FROM bronze.efuse_events_managed;

SELECT
  CAST(key AS STRING) AS message_key,
  CAST(value AS STRING) AS json_payload,
  _kafka_metadata.topic,
  _kafka_metadata.partition,
  _kafka_metadata.offset,
  _kafka_metadata.timestamp
FROM bronze.efuse_events_managed
ORDER BY _kafka_metadata.partition, _kafka_metadata.offset;

SELECT
  CAST(key AS STRING) AS vehicle_key,
  CAST(value AS STRING):vehicle_id::STRING AS vehicle_id,
  CAST(value AS STRING):fuse_id::STRING AS fuse_id,
  CAST(value AS STRING):current_a::DOUBLE AS current_a,
  CAST(value AS STRING):voltage_v::DOUBLE AS voltage_v,
  CAST(value AS STRING):switch_state::INT AS switch_state,
  CAST(value AS STRING):event_ts::TIMESTAMP AS event_ts,
  _kafka_metadata.offset AS kafka_offset
FROM bronze.efuse_events_managed
ORDER BY kafka_offset;

DESCRIBE TABLE bronze.efuse_events_managed;
