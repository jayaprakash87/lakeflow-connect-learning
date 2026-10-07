# Lab 02 — Standard Google Drive ingestion

## Objective

Read the **same Google Drive folder** using the standard Google Drive connector and a Lakeflow pipeline.

This path uses Spark/SQL ingestion APIs such as `read_files` / Auto Loader rather than the fully managed connector.

## Same inputs

Keep these identical to Lab 01:

- Google Drive connection
- source folder
- JSON files
- logical Bronze schema

Target:

```text
bronze.efuse_events_standard
```

## SQL example

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

Authentication can still be governed through a Unity Catalog connection, so we are not comparing secure vs insecure credentials.

Instead, we isolate the abstraction difference:

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
| What pipeline/runtime choices are visible? | |
| What monitoring is available? | |
| What extra flexibility do we gain? | |
