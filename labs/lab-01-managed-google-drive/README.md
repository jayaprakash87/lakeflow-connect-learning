# Lab 01 — Managed Google Drive ingestion

## Status

**Completed successfully.** The managed Google Drive ingestion pipeline was created and executed successfully.

## Objective

Ingest structured eFuse JSON files from a Google Drive folder using the **managed Lakeflow Connect Google Drive connector**.

## Source

```text
Google Drive
  lakeflow-connect-learning/
    batch-001.json
```

The source file contains the sample eFuse records from `sample-data/efuse-events.json`.

## Target

```text
bronze.efuse_events_managed
```

## What was configured

- Unity Catalog Google Drive connection
- managed ingestion pipeline
- structured-table ingestion
- JSON source format
- Google Drive folder as source
- Bronze destination table
- pipeline event-log location
- manual first run

## What was NOT implemented by us

We did not write:

- `read_files`
- `spark.readStream`
- Auto Loader code
- file-discovery logic
- explicit checkpoint handling
- retry loops
- custom ingestion runtime code

## Learning result

This lab demonstrated the practical meaning of a **managed ingestion layer**:

> We declared the source, source format, destination, and pipeline behavior, while Databricks operated the ingestion machinery.

The important observation is not simply that there was less code. The ingestion responsibility boundary moved toward the platform.

## Objects created/used

```text
Google Drive folder
      ↓
Unity Catalog connection
      ↓
Managed Lakeflow Connect pipeline
      ├── pipeline event log / monitoring
      └── destination streaming table
             ↓
      bronze.efuse_events_managed
```

## Completion checklist

- [x] Google Drive source folder created
- [x] eFuse sample JSON uploaded
- [x] Unity Catalog connection created
- [x] managed ingestion pipeline created
- [x] structured-table ingestion selected
- [x] destination configured
- [x] pipeline executed successfully
- [x] target table created/populated

## Questions to answer before Lab 02

| Question | Lab 01 observation |
|---|---|
| Did we write ingestion SQL/code? | No |
| Did we configure a checkpoint path? | No |
| Did we implement file discovery? | No |
| Did we implement retry logic? | No |
| Where did authentication live? | Unity Catalog connection |
| Who operated the ingestion runtime? | Databricks managed pipeline |
| Where did business data land? | Bronze destination table |
| Where did pipeline operational information appear? | Event log / pipeline monitoring |
| How was JSON handling selected? | Managed connector configuration |
| What is still our responsibility? | Source choice, format, destination, permissions, schedule/options, downstream transformations |

## Next lab

Proceed to:

```text
Lab 02 — Standard Google Drive ingestion
```

The same source will now be ingested using explicit `read_files` / Auto Loader semantics so we can compare the responsibility boundary directly.
