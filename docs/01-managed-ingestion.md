# Managed ingestion: the concept

A **managed ingestion layer** lets us declare ingestion intent while the platform owns more of the recurring operational machinery.

## We define

- source connection
- source object, folder, topic, or table
- destination
- schedule or continuous mode
- connector-specific options

## The platform manages more of

- incremental state
- retries and recovery
- source-specific protocol behavior
- runtime lifecycle
- destination writes
- monitoring
- connector-specific schema handling

The important distinction is not "code versus no code." It is **responsibility ownership**.

## Current lab example

### Managed

```text
Google Drive folder
      ↓
Managed Google Drive connector
      ↓
bronze.efuse_events_managed
```

We configure the connection, folder URL, JSON format, destination, and schema-evolution policy.

### Standard

```text
Google Drive folder
      ↓
read_files / Auto Loader
      ↓
Lakeflow pipeline
      ↓
bronze.efuse_events_standard
```

We explicitly author the ingestion SQL or PySpark.

## Managed does not mean zero configuration

Managed ingestion still requires architectural choices. It moves more generic ingestion mechanics from our pipeline code into the platform.

Later labs repeat the same concept for PostgreSQL CDC and Kafka, where incremental positions and continuous streaming state become more explicit.
