# Lab 01 — Managed Google Drive ingestion

## Objective

Ingest structured eFuse JSON files from a Google Drive folder using the **managed Lakeflow Connect Google Drive connector**.

## Why this is first

Databricks provides both managed and standard Google Drive connectors, so we can compare two ingestion abstractions against the same source without provisioning a paid external streaming service.

## Source

Create one Google Drive folder:

```text
lakeflow-connect-learning/
  batch-001.json
```

Use `sample-data/efuse-events.json` as the contents of `batch-001.json`.

## Target

```text
bronze.efuse_events_managed
```

## Prerequisites

- Unity Catalog enabled
- serverless compute enabled
- `CREATE CONNECTION` to create the connection, or `USE CONNECTION` on an existing one
- a Google account with read access to the source folder

## Authentication

Prefer **OAuth U2M: Databricks-managed** when it is available in the workspace. It requires no Google Cloud project or custom OAuth app.

## Managed pipeline configuration

Conceptually:

```text
Connection: lab_google_drive_connection
Entity: FILE
URL: <Google Drive folder URL>
Format: JSON
Schema evolution: ADD_NEW_COLUMNS_WITH_TYPE_WIDENING (default)
Destination: bronze.efuse_events_managed
```

## What we do not write

We do not write:

- `read_files`
- `spark.readStream`
- Auto Loader code
- file-discovery logic
- retry loops
- checkpoint-path code

That absence is the learning point.

## Observation table

| Question | Observation |
|---|---|
| How was authentication configured? | |
| How was the folder selected? | |
| Where was JSON format configured? | |
| Where was schema evolution configured? | |
| How is incremental progress maintained? | |
| What retry/recovery controls are exposed? | |
| What objects did Databricks create? | |
| How is pipeline health monitored? | |
