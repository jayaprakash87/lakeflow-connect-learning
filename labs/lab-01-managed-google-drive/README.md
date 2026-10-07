# Lab 01 — Managed Google Drive ingestion

## Why this is the first executable lab

Google Drive lets us study the managed-ingestion abstraction without provisioning a paid Kafka service.

Databricks supports a managed Google Drive connector that handles source authentication, incremental reads, retries, schema handling, and destination writes through a managed ingestion pipeline.

## Controlled source

Create one Google Drive folder, for example:

```text
lakeflow-connect-learning/
  batch-001.json
```

Use the repository's sample eFuse JSON as the content.

## Target

```text
bronze.efuse_events_managed
```

## Connection

Create a Unity Catalog Google Drive connection.

Prefer **Databricks-managed OAuth U2M** if your workspace exposes it. This requires no Google Cloud project or custom OAuth app.

Conceptually:

```text
Google account
    ↓ OAuth
Unity Catalog connection
    ↓
Managed ingestion pipeline
    ↓
bronze.efuse_events_managed
```

## Pipeline intent

Configure the managed connector to:

- read the Google Drive folder;
- interpret files as JSON;
- ingest incrementally;
- write to the managed destination table.

## What we do NOT write

We do not write:

- `spark.read`
- `read_files`
- Auto Loader configuration
- file discovery logic
- retry loops
- ingestion checkpoint code

That absence is the key learning point.

## Observation table

| Question | Observation |
|---|---|
| How was authentication configured? | |
| How was the source folder selected? | |
| How was JSON format configured? | |
| Where is schema evolution configured? | |
| How is incremental progress maintained? | |
| What retry/recovery controls are exposed? | |
| What objects did Databricks create? | |
| How is pipeline health monitored? | |
