# Lab 06 — Prerequisites

## Goal

Use the smallest Kafka environment that lets us observe the **managed Lakeflow Connect Kafka connector**.

## Databricks requirements

Verify:

- Unity Catalog is enabled.
- Serverless compute is enabled.
- Lakeflow Connect for Kafka is enabled in Previews.
- You can create or use a Unity Catalog connection.
- You have target catalog/schema/table privileges.
- Databricks serverless networking can reach the Kafka brokers.

The managed Kafka connector is currently Beta.

## Kafka requirements

You need:

- one reachable Kafka-compatible cluster or service;
- topic `efuse-events`;
- credentials with permission to read the topic;
- bootstrap server address.

Do not provision a paid service only for this repository. Execute this lab when a reachable Kafka environment is already available.

## Expected Databricks objects

```text
Kafka
  ↓
Unity Catalog connection
  ↓
Managed Lakeflow Connect pipeline
  ↓
Streaming table
  ↓
bronze.efuse_events_managed
```

## Keep the experiment narrow

Do not add multiple topics, fanout, complex deserialization, production networking design, or CI/CD until the managed-ingestion responsibility boundary is understood.
