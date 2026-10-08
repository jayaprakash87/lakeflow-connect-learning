# Lab 02 — Standard Google Drive ingestion

## Objective

Read the **same Google Drive folder** with the standard Google Drive connector in a Lakeflow pipeline.

The standard connector exposes Spark/SQL ingestion APIs such as `read_files`, Auto Loader, `spark.read`, and `COPY INTO`.

## Same inputs as Lab 01

Keep these identical:

- Unity Catalog Google Drive connection
- source folder
- JSON files
- destination catalog/schema

Target:

```text
bronze.efuse_events_standard
```

## Important runtime requirement

For Google Drive in a Lakeflow pipeline:

- Databricks Runtime **17.3 or later** is required.
- Set the pipeline channel to **PREVIEW**.

## Make the source URL configurable

Do **not** hardcode the Google Drive URL in the SQL file.

In the Lakeflow pipeline settings, add a configuration entry:

```text
Key:   lab.source_url
Value: <your Google Drive folder URL>
```

Example:

```text
lab.source_url =
https://drive.google.com/drive/u/0/folders/1j26GKyWwByLrYnylUK8H48scvy-m-swj
```

The SQL then references it with pipeline configuration interpolation:

```sql
'${lab.source_url}'
```

See `standard_ingestion.sql`.

## SQL

```sql
CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '${lab.source_url}',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

## Why this is better

The repository stays reusable:

```text
Code in GitHub
      +
User/workspace-specific configuration
      ↓
Executable pipeline
```

The Google Drive folder can change without changing or recommitting pipeline code.

This also gives us a useful architectural lesson:

> **Configuration values belong outside code when they vary by user, workspace, or environment.**

## Why this is the right managed-vs-standard comparison

Authentication remains governed through the same Unity Catalog connection.

The variable is therefore:

```text
Managed connector
  → configure ingestion intent

Standard connector
  → author Spark/SQL ingestion behavior
```

## Observation table

| Question | Observation |
|---|---|
| Did we write ingestion SQL/code? | |
| Where did the source URL live? | Pipeline configuration |
| Who invokes `read_files`? | |
| Where is format configuration? | |
| How is incremental file discovery handled? | |
| How is schema evolution controlled? | |
| Which runtime/channel requirements are visible? | |
| What monitoring is available? | |
| What extra flexibility do we gain? | |
