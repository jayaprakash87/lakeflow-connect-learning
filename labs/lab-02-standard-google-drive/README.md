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
- Standard Google Drive pipeline creation is API/code based rather than UI-authored.

## SQL

See `standard_ingestion.sql`.

The key operation is:

```sql
CREATE OR REFRESH STREAMING TABLE bronze.efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '<GOOGLE_DRIVE_FOLDER_URL>',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

## Why this is the right comparison

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
| Who invokes `read_files`? | |
| Where is format configuration? | |
| How is incremental file discovery handled? | |
| How is schema evolution controlled? | |
| Which runtime/channel requirements are visible? | |
| What monitoring is available? | |
| What extra flexibility do we gain? | |
