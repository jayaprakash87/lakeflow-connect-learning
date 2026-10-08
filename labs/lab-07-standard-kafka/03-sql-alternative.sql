-- Lab 07 — SQL alternative using read_kafka()
-- Replace values with your environment.
--
-- For a service credential, uncomment:
--   serviceCredential => '<service-credential-name>',

CREATE OR REFRESH STREAMING TABLE efuse_events_standard_sql
AS
SELECT
  key,
  value,
  named_struct(
    'topic', topic,
    'partition', partition,
    'offset', offset,
    'timestamp', timestamp,
    'timestampType', timestampType,
    'headers', headers
  ) AS _kafka_metadata
FROM STREAM read_kafka(
  bootstrapServers => '<broker-host:port>',
  subscribe => 'efuse-events',
  startingOffsets => 'earliest'
  -- ,serviceCredential => '<service-credential-name>'
);
