# Lab 03 — Incremental state, reruns, and recovery

## Objective

Use the **same two pipelines from Labs 01 and 02** to understand how ingestion state survives across pipeline runs.

We are testing:

```text
same Google Drive folder
        ↓
┌───────────────────────────────┐
│ Lab 01: managed connector     │
│ Lab 02: standard read_files   │
└───────────────────────────────┘
        ↓
two Bronze tables
```

The core question is:

> After a successful first run, how does each ingestion path know what it has already processed?

---

# Expected starting state

Before starting Lab 03, both earlier labs should have succeeded with `batch-001.json`.

The first file contains **3 records**.

Expected tables:

```text
<catalog>.bronze.efuse_events_managed    → 3 rows
<catalog>.bronze.efuse_events_standard   → 3 rows
```

Use your actual catalog name. Examples below use `workspace`.

Verify:

```sql
SELECT COUNT(*) AS managed_count
FROM workspace.bronze.efuse_events_managed;

SELECT COUNT(*) AS standard_count
FROM workspace.bronze.efuse_events_standard;
```

Do not continue until both counts are 3.

---

# Experiment A — Add a NEW file

This is the main experiment and the safest way to understand incremental ingestion.

## Step 1 — Prepare batch-002.json

The repository contains:

```text
sample-data/efuse-events-batch-002.json
```

It contains two new eFuse records.

Upload it into the **same Google Drive folder**:

```text
lakeflow-connect-learning/
  batch-001.json
  batch-002.json
```

Do not modify or replace `batch-001.json`.

---

## Step 2 — Rerun the managed pipeline

Go to:

```text
Jobs & pipelines
  → lab-managed-gdrive-efuse
```

Run the ingestion pipeline normally.

Important:

```text
Use normal Run / Update
Do NOT perform a Full refresh
Do NOT reset the pipeline
```

A full refresh intentionally discards/rebuilds ingestion state and would invalidate this experiment.

Wait until the update succeeds.

---

## Step 3 — Validate the managed destination

Run:

```sql
SELECT COUNT(*) AS managed_count
FROM workspace.bronze.efuse_events_managed;
```

Expected:

```text
5
```

Then inspect the actual rows:

```sql
SELECT *
FROM workspace.bronze.efuse_events_managed
ORDER BY event_ts;
```

### What this proves

The managed Google Drive connector did **not** ingest `batch-001.json` again.

It remembered that the first file had already been processed and ingested only the newly added file.

Databricks manages that incremental source state for the managed connector.

---

## Step 4 — Rerun the standard ETL pipeline

Go to:

```text
Jobs & pipelines
  → lab-standard-gdrive-efuse
```

Run the pipeline normally.

Again:

```text
Do NOT use Full refresh
Do NOT reset state
```

Wait for success.

---

## Step 5 — Validate the standard destination

Run:

```sql
SELECT COUNT(*) AS standard_count
FROM workspace.bronze.efuse_events_standard;
```

Expected:

```text
5
```

Then:

```sql
SELECT *
FROM workspace.bronze.efuse_events_standard
ORDER BY event_ts;
```

### What this proves

The `read_files(...)` call is streaming-file ingestion backed by Auto Loader semantics.

The standard path also retains progress across pipeline updates, so it does not blindly reread every existing file on each normal run.

The difference is **not**:

```text
managed = stateful
standard = stateless
```

Both are stateful.

The difference is how much of that state-management implementation is exposed to us.

---

# Experiment B — Rerun WITHOUT changing Google Drive

Now run both pipelines again without adding or changing any files.

Expected counts remain:

```text
managed  = 5
standard = 5
```

Run:

```sql
SELECT COUNT(*) FROM workspace.bronze.efuse_events_managed;
SELECT COUNT(*) FROM workspace.bronze.efuse_events_standard;
```

This is an important observation:

> A normal rerun does not mean "read the whole source again."

The ingestion systems retain progress from previous successful runs.

---

# Experiment C — Add data while pipelines are idle

This simulates a small outage or scheduled gap.

## Step 1

Do not run either pipeline.

## Step 2

Upload:

```text
batch-003.json
```

Use the repository sample file:

```text
sample-data/efuse-events-batch-003.json
```

It contains two more records.

The Drive folder is now:

```text
lakeflow-connect-learning/
  batch-001.json
  batch-002.json
  batch-003.json
```

## Step 3

Wait a few minutes if you want to simulate downtime.

No ingestion is occurring while the pipelines are idle.

## Step 4

Run the managed pipeline.

Expected count:

```text
7
```

## Step 5

Run the standard pipeline.

Expected count:

```text
7
```

### Learning result

Neither pipeline needs the source file to arrive while the pipeline is actively running.

On the next update, each discovers the new data relative to its previously persisted progress.

---

# Experiment D — Inspect operational evidence

Counts prove the result, but we also want to inspect **where state and progress are visible**.

## Managed pipeline

Open:

```text
Jobs & pipelines
  → lab-managed-gdrive-efuse
  → latest successful update
```

Inspect:

- update history
- source progress
- files/rows processed if shown
- event log
- start/end times
- errors/retries if any

Record whether Databricks exposes an explicit checkpoint path to you.

Expected learning:

```text
We did not create or configure one.
```

The managed connector owns the source progress machinery.

---

## Standard ETL pipeline

Open:

```text
Jobs & pipelines
  → lab-standard-gdrive-efuse
  → latest successful update
```

Inspect:

- streaming table
- update history
- flow progress
- input/output row metrics
- event log

Our SQL contains:

```sql
FROM STREAM read_files(...)
```

but we still did not manually specify a Structured Streaming checkpoint directory.

Within a Lakeflow pipeline, Databricks manages the pipeline's streaming state for the streaming table.

This is an important nuance:

> "Standard connector" means more ingestion logic is ours; it does not mean Lakeflow stops managing all streaming execution state.

---

# Experiment E — Modified existing file (important difference)

Do this only after Experiments A–D are understood.

This experiment shows why **new immutable files** are the normal ingestion pattern.

## Managed connector behavior

For the managed Google Drive connector, subsequent runs can detect files that were **added or updated** since the prior run.

For structured formats, the default storage mode is append-only.

Therefore, if an already-ingested structured file changes, the connector can re-ingest the **whole updated file** and append its rows.

It does not detect only the individual changed JSON/CSV rows inside that file.

### Consequence

If `batch-001.json` originally has 3 rows and you replace it with a version containing those same 3 rows plus one new row, a managed append-only ingestion can append the updated file contents.

You can therefore create duplicate business rows unless your architecture treats input files as immutable or deduplicates downstream.

---

## Standard read_files behavior

For streaming `read_files`, the default is:

```text
allowOverwrites = false
```

That means an already-discovered path is normally treated as already processed.

If you intentionally want changed files to be reprocessed, you can opt into:

```sql
allowOverwrites => true
```

but then you must design for duplicate records because an updated file is reprocessed as a file, not as a row-level CDC stream.

## Recommendation

For this learning lab and for most append-oriented file ingestion:

```text
Prefer:
batch-001.json
batch-002.json
batch-003.json

Avoid:
continuously overwriting batch-001.json
```

File ingestion is not row-level CDC.

---

# Recovery vs Full refresh

These terms must not be confused.

## Normal rerun / restart

```text
previous state
    ↓
pipeline starts again
    ↓
continues incrementally
```

This is what Lab 03 tests.

## Full refresh / reset

```text
discard/rebuild state
    ↓
reprocess source
    ↓
rebuild destination
```

That is a different operation.

Do not use full refresh during the incremental-state experiments.

---

# Final comparison

Complete this after all experiments:

| Question | Managed Google Drive | Standard Google Drive |
|---|---|---|
| First run ingests existing files? | | |
| New file found on next run? | | |
| Old unchanged file reread? | | |
| Rerun with no changes adds rows? | | |
| Data arriving while idle found later? | | |
| Did we configure checkpoint location? | | |
| Who owns source discovery logic? | Managed connector | `read_files` / Auto Loader |
| Who persists execution state? | Databricks | Lakeflow streaming table runtime |
| Updated existing file behavior | Re-ingests changed file | Not by default |
| Row-level CDC? | No | No |

---

# Expected row-count checkpoints

Using the supplied sample files:

| Stage | Managed | Standard |
|---|---:|---:|
| After batch-001 | 3 | 3 |
| Add batch-002 and rerun | 5 | 5 |
| Rerun with no changes | 5 | 5 |
| Add batch-003 while idle | 7 | 7 |

If your counts differ, **stop and investigate before continuing**.

---

# What Lab 03 should teach you

The naïve mental model is:

```text
pipeline runs
→ scans everything
→ writes everything again
```

The correct incremental-ingestion model is:

```text
Run 1
batch-001
   ↓
persist progress

Run 2
batch-001  ← already known
batch-002  ← new
   ↓
process batch-002
   ↓
persist new progress

Run 3
no new files
   ↓
nothing new to ingest

Run 4
batch-003 arrives
   ↓
process batch-003
```

And the key architectural distinction remains:

```text
Managed connector:
Databricks owns more of source-specific ingestion behavior.

Standard connector:
We explicitly choose read_files / Auto Loader behavior,
while Lakeflow still manages the pipeline's streaming execution state.
```

Once this is clear, proceed to **Lab 04 — Schema Evolution**.
