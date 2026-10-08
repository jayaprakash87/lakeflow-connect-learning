# Lab 02 — Standard Google Drive ingestion

## Objective

Read the **same Google Drive folder** as Lab 01, but this time with the standard Google Drive connector using explicit SQL / Spark ingestion logic.

This is the direct comparison:

```text
Lab 01
Google Drive
   ↓
Managed connector
   ↓
bronze.efuse_events_managed

Lab 02
Google Drive
   ↓
read_files / Auto Loader
   ↓
Lakeflow ETL pipeline
   ↓
bronze.efuse_events_standard
```

## Important difference from Lab 01

For Lab 02, **do not create an Ingestion pipeline**.

In the current Databricks UI:

```text
Jobs & pipelines
  → Create new
      → ETL pipeline
```

Choose **ETL pipeline**.

Why:

- **Ingestion pipeline** = managed connector path used in Lab 01
- **ETL pipeline** = SQL/Python pipeline where we explicitly write ingestion logic
- **Job** = orchestration of notebooks, pipelines, queries, etc.

This UI choice is the first visible manifestation of the managed-vs-standard distinction.

## Step-by-step execution

### Step 1 — Reuse the Lab 01 connection

Use:

```text
lab_google_drive_connection
```

Do not create another Google Drive connection.

This keeps authentication constant while only the ingestion abstraction changes.

---

### Step 2 — Create the correct pipeline type

Go to:

```text
Jobs & pipelines
  → Create new
  → ETL pipeline
```

Do **not** choose:

```text
Ingestion pipeline
```

That would take us back to the managed connector path from Lab 01.

Pipeline name:

```text
lab-standard-gdrive-efuse
```

---

### Step 3 — Configure the ETL pipeline

Set:

```text
Channel: PREVIEW
```

Recommended destination defaults:

```text
Catalog: main
Schema:  bronze
```

If your workspace uses another learning catalog, substitute it consistently.

---

### Step 4 — Add the source URL as pipeline configuration

Do not hardcode the Google Drive URL in SQL.

In the pipeline configuration / advanced configuration section, add:

```text
Key:   lab.source_url
Value: <your Google Drive folder URL>
```

For the current lab:

```text
https://drive.google.com/drive/u/0/folders/1j26GKyWwByLrYnylUK8H48scvy-m-swj
```

---

### Step 5 — Add the SQL source

Use:

```text
labs/lab-02-standard-google-drive/standard_ingestion.sql
```

Core logic:

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

This is the key difference from Lab 01:

> In Lab 01, the managed connector owned the ingestion implementation.  
> In Lab 02, we explicitly author the ingestion logic.

---

### Step 6 — Run the pipeline

Run:

```text
lab-standard-gdrive-efuse
```

The pipeline should incrementally discover the same JSON files in the same Google Drive folder.

---

### Step 7 — Validate the destination

Run:

```sql
SELECT *
FROM main.bronze.efuse_events_standard;

SELECT COUNT(*)
FROM main.bronze.efuse_events_standard;

DESCRIBE TABLE main.bronze.efuse_events_standard;
```

With the current sample file, the expected row count is:

```text
3
```

---

### Step 8 — Compare with Lab 01

| Responsibility | Lab 01 managed | Lab 02 standard |
|---|---|---|
| Pipeline type in UI | Ingestion pipeline | ETL pipeline |
| Google Drive connection | Configure | Reuse |
| Folder URL | Wizard configuration | Pipeline configuration |
| JSON format | Wizard configuration | SQL |
| Ingestion table definition | Managed connector | We write it |
| `read_files` | Hidden from us | We call it |
| Streaming table declaration | Managed | We define it |
| Incremental file discovery | Managed | Auto Loader/read_files semantics |
| Runtime/channel requirement | Mostly managed | Visible to us |
| Transformation flexibility | Lower | Higher |
| Code ownership | Very low | Higher |

## What to observe carefully

Do not focus only on the fact that Lab 02 has SQL.

Look for the responsibility shift:

```text
Lab 01:
"Configure what I want."

Lab 02:
"Write how Databricks should ingest it."
```

That is the managed-vs-standard connector distinction we are trying to learn.
