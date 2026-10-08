# Lab 06 — Create the managed Kafka ingestion pipeline

## Target architecture

```text
Kafka topic: efuse-events
        ↓
lab_kafka_connection
        ↓
Lakeflow Connect managed Kafka ingestion pipeline
        ↓
bronze.efuse_events_managed
```

## Important Beta limitation

At the time of this lab, **UI-based pipeline authoring is not supported for the managed Kafka connector**.

Create the ingestion pipeline using either:

1. a **Databricks notebook**, or
2. **Declarative Automation Bundles**.

For learning, start with the notebook path because it exposes the connector definition without adding bundle/deployment complexity. Later we can reproduce the same pipeline with a bundle.

## Core connector intent

For the first run, keep the behavior simple:

```text
connection: lab_kafka_connection
topic: efuse-events
starting offset: earliest
mode: continuous
destination: bronze.efuse_events_managed
```

Using `earliest` makes the experiment observable because existing test messages are ingested. The starting offset is used only when no checkpoint exists.

## Why continuous mode?

Kafka is an event stream. The managed Kafka connector continuously reads from one or more topics and writes to streaming tables.

## Destination semantics

Each configured Kafka topic is ingested into a Databricks streaming table.

The connector writes message key and value to the destination. Kafka metadata such as topic, partition, offset, timestamp, timestamp type, and headers is not included by default.

For our recovery lab we should enable a `source_metadata_column` so we can inspect offsets and prove what happens across restart.

## What Databricks is operating

After creation, identify:

1. Unity Catalog connection
2. managed ingestion pipeline
3. serverless ingestion runtime
4. destination streaming table
5. pipeline monitoring/event information

## Success criterion

Produce several test events to `efuse-events`.

Then query:

```sql
SELECT *
FROM bronze.efuse_events_managed;
```

Record the actual destination schema rather than assuming it.
