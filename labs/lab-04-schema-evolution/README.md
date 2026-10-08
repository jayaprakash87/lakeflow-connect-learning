# Lab 04 — Schema evolution

## Objective

Use the same Google Drive source and the same two pipelines from Labs 01–03 to understand how **schema evolution** behaves in:

1. the managed Google Drive connector, and
2. the standard Google Drive connector using `read_files` / Auto Loader.

The central question is:

> What happens when a new source column appears after the table already exists?

---

# Starting state

Before Lab 04, both pipelines should already have processed:

```text
batch-001.json
batch-002.json
batch-003.json
```

Expected row count:

```text
managed  = 7
standard = 7
```

Verify:

```sql
SELECT COUNT(*) FROM workspace.bronze.efuse_events_managed;
SELECT COUNT(*) FROM workspace.bronze.efuse_events_standard;
```

Also inspect the current schema:

```sql
DESCRIBE TABLE workspace.bronze.efuse_events_managed;
DESCRIBE TABLE workspace.bronze.efuse_events_standard;
```

At this point there should be no `temperature_c` column.

---

# Experiment A — Add a new column

## Step 1 — Upload batch-004.json

Use:

```text
sample-data/efuse-events-batch-004-temperature.json
```

This file contains two new rows with an extra field:

```json
"temperature_c": 62
```

Upload it into the same Google Drive folder.

The folder becomes:

```text
lakeflow-connect-learning/
  batch-001.json
  batch-002.json
  batch-003.json
  batch-004.json
```

---

# Managed connector behavior

## Step 2 — Run the managed pipeline

Open:

```text
Jobs & pipelines
  → lab-managed-gdrive-efuse
```

Run a normal update.

Do **not** use Full refresh.

The managed Google Drive connector defaults to:

```text
ADD_NEW_COLUMNS_WITH_TYPE_WIDENING
```

This means new columns are added automatically and supported type widening is allowed.

After success, run:

```sql
DESCRIBE TABLE workspace.bronze.efuse_events_managed;
```

Expected new column:

```text
temperature_c
```

Then:

```sql
SELECT
  vehicle_id,
  fuse_id,
  temperature_c,
  event_ts
FROM workspace.bronze.efuse_events_managed
ORDER BY event_ts;
```

Older rows should normally show `NULL` for `temperature_c`.

Expected row count:

```text
9
```

---

# Standard connector behavior

## Step 3 — Run the standard ETL pipeline

The standard pipeline currently uses:

```sql
read_files(..., format => 'json')
```

When no explicit schema is provided, Auto Loader's default schema evolution mode is:

```text
addNewColumns
```

When Auto Loader discovers a new column, it updates its inferred schema and the stream can fail with an `UnknownFieldException` so that it can restart with the new schema.

In a Lakeflow pipeline, restart behavior can be managed by the pipeline runtime, but the key point is that the schema-evolution mechanism is now part of the `read_files` / Auto Loader semantics that we selected explicitly.

Run:

```text
lab-standard-gdrive-efuse
```

Then inspect:

```sql
DESCRIBE TABLE workspace.bronze.efuse_events_standard;
```

Expected:

```text
temperature_c
```

Then:

```sql
SELECT
  vehicle_id,
  fuse_id,
  temperature_c,
  event_ts
FROM workspace.bronze.efuse_events_standard
ORDER BY event_ts;
```

Expected row count:

```text
9
```

If the update stops on first detection of the new field, inspect the error and rerun the pipeline normally. The schema may already have been updated for the next run.

---

# Experiment B — Compare schema-evolution modes

This experiment is about policy, not just default behavior.

## Managed connector modes

The managed Google Drive connector supports:

```text
ADD_NEW_COLUMNS_WITH_TYPE_WIDENING   ← default
ADD_NEW_COLUMNS
RESCUE
FAIL_ON_NEW_COLUMNS
NONE
```

## Standard Auto Loader / read_files modes

The standard connector supports:

```text
addNewColumns                        ← default when schema is inferred
addNewColumnsWithTypeWidening
rescue
failOnNewColumns
none
```

These modes are conceptually aligned.

---

# Experiment C — Strict schema contract

Now we deliberately make both paths reject an unexpected column.

## Managed connector

Edit the managed Google Drive ingestion configuration and change:

```text
schema_evolution_mode
```

to:

```text
FAIL_ON_NEW_COLUMNS
```

Then upload:

```text
sample-data/efuse-events-batch-005-strict-failure.json
```

which introduces:

```json
"diagnostic_code": "OC_WARN"
```

Run the managed pipeline.

Expected result:

```text
pipeline fails because a new column was introduced
```

Inspect the pipeline error and event log.

Do not Full refresh.

---

## Standard connector

Create a temporary variant of the Lab 02 SQL using:

```sql
schemaEvolutionMode => 'failOnNewColumns'
```

Example:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_strict
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  schemaEvolutionMode => 'failOnNewColumns',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

Run the ETL pipeline.

Expected result when a previously unknown field is encountered:

```text
stream fails and schema is not evolved automatically
```

---

# Experiment D — Rescue unexpected fields

A strict failure is useful for certified schemas, but sometimes you want ingestion to continue while preserving unexpected data.

## Standard connector

Create another temporary table:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_rescue
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  schemaEvolutionMode => 'rescue',
  rescuedDataColumn => '_rescued_data',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

With `rescue`:

- the table schema does not automatically add unexpected fields;
- ingestion continues;
- unexpected fields are captured in `_rescued_data`.

Inspect:

```sql
SELECT
  vehicle_id,
  fuse_id,
  _rescued_data
FROM workspace.bronze.efuse_events_standard_rescue
WHERE _rescued_data IS NOT NULL;
```

## Managed connector

The managed Google Drive connector also supports:

```text
RESCUE
```

Use the managed ingestion settings or pipeline definition to select that schema-evolution mode and compare the resulting destination behavior.

---

# Experiment E — Type widening

Now test a compatible type change.

For example, suppose an inferred integer column later needs a wider numeric type.

The managed connector's default:

```text
ADD_NEW_COLUMNS_WITH_TYPE_WIDENING
```

allows supported widening.

The standard connector can opt into:

```text
addNewColumnsWithTypeWidening
```

Supported examples include:

```text
INT   → BIGINT
FLOAT → DOUBLE
```

Unsupported changes such as:

```text
INT → STRING
```

are not treated as safe widening.

This is a useful distinction:

> Schema evolution is not just "add a column". It can also govern compatible data-type changes.

---

# What each mode means

| Mode | New column | Pipeline | Data retained? |
|---|---|---|---|
| Add new columns | Add to schema | May require restart | Yes |
| Add new + type widening | Add + widen supported types | May require restart | Yes |
| Rescue | Do not add to schema | Continues | Yes, in rescued column |
| Fail on new columns | Do not add | Fails | Source retained, ingestion blocked |
| None | Ignore new column | Continues | New field not exposed unless rescued |

---

# What to observe

Complete this table:

| Question | Managed | Standard |
|---|---|---|
| Default evolution mode | | |
| New column automatically appears? | | |
| Did the first update fail/restart? | | |
| Can unknown fields be rescued? | | |
| Can new fields force failure? | | |
| Can supported numeric types widen? | | |
| Where is the policy configured? | Connector settings | `read_files` options |
| Who owns schema inference mechanics? | Databricks connector | Auto Loader runtime |
| Do we write schema-handling code? | Minimal | More explicit |

---

# Key conceptual lesson

Do not conclude:

```text
managed = schema evolution
standard = no schema evolution
```

That is wrong.

Both support schema evolution.

The actual distinction is:

```text
Managed connector
    ↓
schema behavior expressed as connector policy

Standard connector
    ↓
schema behavior expressed explicitly in read_files / Auto Loader options
```

So the learning progression is:

```text
Lab 01 → who owns ingestion?
Lab 02 → what changes when we write ingestion logic?
Lab 03 → how is incremental state preserved?
Lab 04 → how is schema change policy expressed?
```

After this lab, move to **Lab 05 — PostgreSQL CDC**, where incremental state becomes row-level change capture instead of file-level ingestion.
