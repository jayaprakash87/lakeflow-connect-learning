# Controlled experiment design

To learn managed ingestion correctly, change one variable at a time.

## Constant across Lab 01 and Lab 02

```text
Google Drive account
Unity Catalog connection
Source folder
Source JSON files
Destination catalog/schema
Logical Bronze schema
```

## Variable

```text
Ingestion abstraction
```

### Lab 01

```text
Managed Lakeflow Connect Google Drive connector
```

### Lab 02

```text
Standard Google Drive connector using read_files / Auto Loader
```

## Why this matters

If we change the source, file format, authentication model, or transformation logic at the same time, we cannot tell which differences came from the managed-ingestion abstraction.

## First experiment

Both paths ingest the same JSON files with minimal transformation.

Then we deliberately test:

1. incremental arrival of a second file;
2. restart/recovery;
3. a new source column;
4. schema-evolution policy.

## Later experiments

PostgreSQL CDC and Kafka remain valuable follow-up labs because they expose CDC positions and streaming offsets more explicitly.
