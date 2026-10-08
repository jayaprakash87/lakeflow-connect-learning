# Managed Google Drive — exact UI walkthrough

This file follows the current Databricks **Add data → Google Drive** wizard screen by screen.

## Before opening the wizard

In Google Drive:

1. Create a folder named `lakeflow-connect-learning`.
2. Upload `batch-001.json` using the newline-delimited records from `sample-data/efuse-events.json`.
3. Copy the **folder URL**.

Recommended Databricks objects for this lab:

```text
Connection:        lab_google_drive_connection
Pipeline:          lab-managed-gdrive-efuse
Event-log catalog: main                 # or your learning catalog
Event-log schema:  lakeflow_lab_meta
Destination:       main.bronze
Target table:      efuse_events_managed
```

If you cannot use `main`, substitute a Unity Catalog catalog where you have the required privileges.

---

## Step 1 — Connection

Open:

```text
Data Ingestion
  → Google Drive
```

Select:

```text
lab_google_drive_connection
```

Then click **Next**.

The connection is a Unity Catalog object that stores the Google Drive authentication context. It is separate from the ingestion pipeline.

---

## Step 2 — Ingestion setup

This is the screen that contains **Pipeline name**, **Event log location**, and the **Structured tables / Unstructured data** choice.

### 2.1 Pipeline name

Enter:

```text
lab-managed-gdrive-efuse
```

This names the Lakeflow ingestion pipeline itself. It is **not** the destination table name.

### 2.2 Event log location

Choose a Unity Catalog **catalog** and **schema**, for example:

```text
Catalog: main
Schema:  lakeflow_lab_meta
```

The event log records operational information about the pipeline: starts, updates, failures, progress, and related execution events.

**Do not confuse this with the final Bronze destination.**

For this learning lab we deliberately separate them:

```text
main.lakeflow_lab_meta    ← pipeline/event-log location
main.bronze               ← ingested business data
```

The wizard later has a separate **Destination** step.

If you do not want to create a dedicated metadata schema, you can use an existing schema where you have privileges, but keeping metadata separate makes the architecture easier to understand.

### 2.3 Structured tables vs Unstructured data

Select:

```text
Structured tables
```

for this lab.

Why:

Our source is JSON:

```json
{"vehicle_id":"V123","fuse_id":"F17","current_a":21.4}
```

We want those fields parsed into Delta columns:

```text
vehicle_id
fuse_id
current_a
voltage_v
switch_state
event_ts
```

Use **Unstructured data** for files such as:

```text
PDF
images
Word documents
other documents used for RAG/document processing
```

In that mode the goal is to preserve file content/reference plus metadata rather than parse records into normal tabular rows.

### 2.4 Advanced settings

For Lab 01, leave Advanced settings at their defaults.

We want to learn the managed ingestion path first. We will deliberately change schema-evolution behavior in Lab 04.

Click:

```text
Create ingestion pipeline and start compute
```

The exact button wording can vary slightly by workspace release.

---

## Step 3 — Source

Now configure **what in Google Drive should be ingested**.

Enter the Google Drive **folder URL** you copied earlier.

For this lab configure:

```text
Source URL:     <Google Drive folder URL>
File type:      Structured
Format:         JSON
```

If the wizard asks for a destination/object name at this stage, use a clear logical name such as:

```text
efuse_events_managed
```

For the first run:

- do not add path filters;
- do not add schema hints;
- keep the default schema-evolution behavior;
- ingest only our controlled lab folder.

Then click **Save and continue**.

---

## Step 4 — Destination

This is where the ingested **business data** should land.

Select:

```text
Catalog: main
Schema:  bronze
```

Target table for this lab:

```text
main.bronze.efuse_events_managed
```

This is intentionally different from the event-log schema.

Mental model:

```text
Google Drive
      ↓
Lakeflow managed ingestion pipeline
      ├── operational events → main.lakeflow_lab_meta
      │
      └── business rows      → main.bronze.efuse_events_managed
```

Click **Save and continue**.

---

## Step 5 — Schedules and notifications

For the first experiment, do **not** add a recurring schedule yet.

We want one controlled manual run so we can inspect exactly what happened.

Leave scheduling/notifications empty and choose:

```text
Save and run pipeline
```

Later we will add a schedule and compare orchestration behavior.

---

## Step 6 — Validate the result

After the run succeeds:

```sql
SELECT *
FROM main.bronze.efuse_events_managed;

SELECT COUNT(*)
FROM main.bronze.efuse_events_managed;

DESCRIBE TABLE main.bronze.efuse_events_managed;
```

Expected result for the repository sample file:

```text
3 rows
```

The JSON attributes should appear as table columns.

---

## Step 7 — Inspect what Databricks created

Before moving to Lab 02, locate and inspect:

1. `lab_google_drive_connection`
2. `lab-managed-gdrive-efuse`
3. the pipeline event log / monitoring view
4. `main.bronze.efuse_events_managed`
5. the pipeline source definition

Then answer:

| Question | Observation |
|---|---|
| Did we write `read_files` or Spark code? | |
| Did we create a checkpoint directory? | |
| Did we implement retry logic? | |
| Where did authentication live? | |
| Where did pipeline operational events go? | |
| Where did business data go? | |
| How was JSON parsing selected? | |
| What schema did Databricks infer? | |

Those answers are the practical meaning of **managed ingestion**.
