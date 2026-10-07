# Lab 01 — Create the managed Kafka ingestion pipeline

## Target architecture

```text
Kafka topic: efuse-events
        ↓
lab_kafka_connection
        ↓
Lakeflow Connect ingestion pipeline
        ↓
bronze.efuse_events_managed
```

## Core connector configuration

For the first run, keep the connector behavior simple:

```text
connection: lab_kafka_connection
topic: efuse-events
starting offset: earliest
mode: continuous
destination: bronze.efuse_events_managed
```

Using `earliest` for the first lab makes the experiment observable because existing test messages are ingested. The starting offset matters only when no checkpoint exists.

## Important behavior to observe

The managed Kafka connector continuously reads Kafka and writes into a Databricks streaming table.

The first version of this lab should preserve the source payload with minimal transformation. We do not want parsing logic to distract from ingestion behavior.

Kafka metadata such as topic, partition, offset, and timestamp is not necessarily included as separate destination columns by default. If we need it for the recovery experiment, enable the connector's source metadata column option.

## Why continuous mode?

Kafka is an event stream, so the managed Kafka connector is intended to run continuously rather than as a batch copy job.

This is a major conceptual difference from a typical scheduled file-copy pipeline.

## What Databricks is now operating

After the pipeline is created, identify these objects in the workspace:

1. Unity Catalog connection
2. ingestion pipeline
3. serverless runtime used by the ingestion pipeline
4. destination streaming table
5. monitoring/event information for the pipeline

## Success criterion

Produce three test events to `efuse-events`.

Then run:

```sql
SELECT *
FROM bronze.efuse_events_managed
ORDER BY event_ts;
```

The exact destination columns depend on the connector transform configuration. Record the observed schema rather than assuming it.
