# Lab 01 — Reproduce the managed connector as code

The managed pipeline can be defined as a Declarative Automation Bundle so the connector definition is visible and version controlled.

## Files

~~~text
databricks.yml
resources/
  kafka_managed_pipeline.yml
~~~

## What the definition says

~~~text
connection = lab_kafka_connection
topic      = efuse-events
start      = earliest, only if no checkpoint exists
target     = <catalog>.bronze.efuse_events_managed
mode       = continuous
runtime    = serverless
channel    = PREVIEW
metadata   = _kafka_metadata
~~~

Notice what is not in this definition:

- Kafka password or API secret
- spark.readStream.format("kafka")
- writeStream
- checkpoint path
- cluster definition
- retry loop
- manual offset persistence

That absence is part of the managed-ingestion abstraction.

## Deployment commands

~~~bash
databricks bundle validate -t dev
databricks bundle deploy -t dev
~~~

Before deployment verify the Kafka preview is enabled, the Unity Catalog connection exists, privileges are available, and serverless networking can reach Kafka.

## Learning question

Compare this small declarative definition with the operational machinery visible in the Databricks pipeline UI. The gap is the managed ingestion layer.
