# Managed connector vs standard connector

We implement the **same Google Drive source** twice.

## Path A — Managed

```text
Google Drive folder
  ↓
Lakeflow Connect managed Google Drive connector
  ↓
bronze.efuse_events_managed
```

We configure the Unity Catalog connection, folder URL, file format, destination, and ingestion options.

## Path B — Standard

```text
Google Drive folder
  ↓
read_files / Auto Loader
  ↓
Lakeflow pipeline
  ↓
bronze.efuse_events_standard
```

We author the Spark/SQL ingestion logic ourselves.

## What stays constant

- Google Drive account and folder
- Unity Catalog connection
- source files
- JSON format
- logical Bronze data
- destination catalog/schema

## What changes

Only the **ingestion abstraction**.

## What we compare

1. setup effort
2. code owned by us
3. source configuration
4. incremental file discovery/state
5. retry and recovery behavior
6. schema evolution
7. runtime requirements
8. monitoring
9. operational burden
10. flexibility

The purpose is not to prove managed is always better. It is to see exactly where the responsibility boundary moves.
