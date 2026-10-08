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
Lakeflow pipeline
   ↓
bronze.efuse_events_standard
```

## Important difference from Lab 01

For the standard Google Drive connector, Databricks currently does **not** support creating this custom ingestion pipeline through the same ingestion wizard.

Databricks documents the standard Google Drive approach as **API/code based**. In practice, for this lab, create a normal Lakeflow pipeline and attach our SQL file.

Requirements:

- Databricks Runtime 17.3+
- pipeline channel = `PREVIEW`
- existing Unity Catalog Google Drive connection
- target catalog/schema privileges

## Step-by-step execution

### Step 1 — Reuse the Lab 01 connection

Use:

```text
lab_google_drive_connection
```

Do not create another Google Drive connection.

This is deliberate: authentication stays constant while the ingestion abstraction changes.

---

### Step 2 — Create a new Lakeflow pipeline

In Databricks, go to the Lakeflow / Jobs & Pipelines area and create a new **pipeline**.

Use:

```text
Pipeline name:
lab-standard-gdrive-efuse
```

This is a standard Lakeflow pipeline, not the managed Google Drive ingestion wizard used in Lab 01.

---

### Step 3 — Configure the pipeline

Set:

```text
Channel: PREVIEW
```

For destination defaults, use the same learning catalog/schema pattern as Lab 01.

Recommended:

```text
Catalog: main
Schema:  bronze
```

If your workspace uses another learning catalog, substitute it consistently.

---

### Step 4 — Add the source URL as pipeline configuration

Do not hardcode the Google Drive URL in the SQL.

In the pipeline configuration / advanced configuration section, add:

```text
Key:   lab.source_url
Value: <your Google Drive folder URL>
```

For your current lab:

```text
https://drive.google.com/drive/u/0/folders/1j26GKyWwByLrYnylUK8H48scvy-m-swj
```

This keeps workspace-specific values out of committed code.

---

### Step 5 — Add the SQL source file

Use the SQL in:

```text
labs/lab-02-standard-google-drive/standard_ingestion.sql
```

The core logic is:

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

This is the key point of Lab 02:

> We are now explicitly authoring the ingestion behavior.

In Lab 01, the managed connector generated/operated this ingestion logic for us.

---

### Step 6 — Run the pipeline

Run:

```text
lab-standard-gdrive-efuse
```

The pipeline should incrementally discover the JSON files in the same Google Drive folder.

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

Now compare:

| Responsibility | Lab 01 managed | Lab 02 standard |
|---|---|---|
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
