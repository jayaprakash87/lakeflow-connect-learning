# Lab 06 — Deploy managed Kafka with a bundle

This advanced lab has its own bundle so the root repository bundle can remain focused on the current Google Drive experiment.

## Files

```text
labs/lab-06-managed-kafka/
  databricks.yml
  kafka_managed_pipeline.yml
```

The definition declares:

```text
connection = lab_kafka_connection
topic      = efuse-events
start      = earliest, only when no checkpoint exists
target     = bronze.efuse_events_managed
mode       = continuous
runtime    = serverless
channel    = PREVIEW
metadata   = _kafka_metadata
```

Notice what is not in the pipeline definition:

- Kafka password or API secret
- `spark.readStream.format("kafka")`
- `writeStream`
- checkpoint path
- cluster definition
- retry loop
- manual offset persistence

## Deploy

Run from the Lab 06 directory:

```bash
cd labs/lab-06-managed-kafka
databricks bundle validate -t dev
databricks bundle deploy -t dev
```

Before deployment verify the Kafka Beta preview is enabled, the Unity Catalog connection exists, target privileges are available, and serverless networking can reach Kafka.
