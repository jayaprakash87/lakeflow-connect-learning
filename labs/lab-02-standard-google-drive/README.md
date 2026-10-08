# Lab 02 — Standard Google Drive ingestion

## Objective

Read the **same Google Drive folder** as Lab 01, but use the standard Google Drive connector through an **ETL pipeline** and explicit SQL.

The comparison is:

```text
Lab 01
Google Drive
  ↓
Ingestion pipeline
  ↓
Managed connector
  ↓
efuse_events_managed

Lab 02
Google Drive
  ↓
ETL pipeline
  ↓
read_files(...)
  ↓
efuse_events_standard
```

---

# Exact UI order

This section follows the current Lakeflow Pipelines Editor.

## Step 1 — Create the correct pipeline type

Go to:

```text
Jobs & pipelines
  → Create new
  → ETL pipeline
```

Do **not** select **Ingestion pipeline**. That is the managed path from Lab 01.

Databricks creates the ETL pipeline immediately and opens the Lakeflow Pipelines Editor.

---

## Step 2 — Rename the pipeline

At the top-left, rename it to:

```text
lab-standard-gdrive-efuse
```

A new pipeline contains a default source file:

```text
transformations/
  my_transformation.py
```

Do not edit it yet.

---

## Step 3 — Set the Default location first

The editor initially asks for:

```text
Default catalog
Default schema
```

This is the screen shown immediately after creating the pipeline.

Set these to the **same catalog/schema where you want the Lab 02 output table to live**.

For example:

```text
Default catalog: workspace
Default schema:  bronze
```

If Lab 01 used a different catalog/schema, use that same location instead.

Then click:

```text
Save
```

### What "Default location" means

It is the catalog/schema used when your SQL creates or reads an **unqualified** table name.

For example:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard
```

will be published as:

```text
<default_catalog>.<default_schema>.efuse_events_standard
```

This is **not** the pipeline event-log location from Lab 01.

---

## Step 4 — Change the transformation file from Python to SQL

Select:

```text
transformations/my_transformation.py
```

At the top of the editor, use the language selector currently showing:

```text
Python
```

and change it to:

```text
SQL
```

The file will become the SQL source for this ETL pipeline.

You can rename it to:

```text
standard_ingestion.sql
```

for clarity.

---

## Step 5 — Configure the Google Drive folder as a parameter

We do not want the Drive URL hardcoded in source code.

Open:

```text
Pipeline settings
  → Parameters
  → Edit
```

Add:

```text
Key:   source_url
Value: <your Google Drive folder URL>
```

Current lab value:

```text
https://drive.google.com/drive/u/0/folders/1j26GKyWwByLrYnylUK8H48scvy-m-swj
```

Then save the parameter.

### Why Parameters?

The folder URL is a runtime/environment input. Pipeline parameters let the same SQL be reused with a different folder without editing Git/source code.

If **Parameters** is not visible in your workspace, use **Settings → Configuration** instead:

```text
lab.source_url = <folder URL>
```

and use the configuration-based SQL variant documented below.

---

## Step 6 — Set the pipeline channel to PREVIEW

Open pipeline settings and set:

```text
Channel: PREVIEW
```

The standard Google Drive connector requires Databricks Runtime 17.3+ and the PREVIEW channel for Lakeflow pipelines.

Keep serverless compute unless you have a specific reason to change it.

---

## Step 7 — Enter the SQL ingestion logic

Preferred parameter-based version:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  :source_url,
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

Because the Default location was configured in Step 3, the table will be created there automatically.

### Fallback if your workspace does not expose Pipeline Parameters

If you used:

```text
Settings → Configuration
lab.source_url = <folder URL>
```

use:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard
AS
SELECT *
FROM STREAM read_files(
  '${lab.source_url}',
  format => 'json',
  `databricks.connection` => 'lab_google_drive_connection'
);
```

---

## Step 8 — Run the pipeline

Click:

```text
Run pipeline
```

The ETL pipeline should discover the same JSON file used in Lab 01 and create:

```text
<default_catalog>.<default_schema>.efuse_events_standard
```

---

## Step 9 — Validate

Use the catalog/schema selected in Step 3.

For example:

```sql
SELECT *
FROM workspace.bronze.efuse_events_standard;

SELECT COUNT(*)
FROM workspace.bronze.efuse_events_standard;

DESCRIBE TABLE workspace.bronze.efuse_events_standard;
```

The sample repository file contains three records, so the first run should produce three rows.

---

# What to compare with Lab 01

| Responsibility | Lab 01 managed | Lab 02 standard |
|---|---|---|
| UI entry point | Ingestion pipeline | ETL pipeline |
| Source connection | Wizard configuration | Referenced in SQL |
| Source folder | Wizard configuration | Pipeline parameter |
| File format | Wizard configuration | SQL |
| Table definition | Managed connector | Written by us |
| `read_files` | Hidden | Explicit |
| Default catalog/schema | Destination step | ETL Default location |
| Runtime/channel details | More hidden | Visible |
| Incremental discovery | Managed connector | `read_files` / Auto Loader semantics |
| Code ownership | Very low | Higher |

## Core learning point

```text
Lab 01:
configure the desired ingestion

Lab 02:
author the ingestion logic
```

Both use Databricks, but the **responsibility boundary** is different.
