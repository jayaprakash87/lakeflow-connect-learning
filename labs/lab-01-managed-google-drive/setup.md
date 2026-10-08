# Managed Google Drive — execution steps

## 1. Prepare the source folder

In Google Drive, create:

```text
lakeflow-connect-learning
```

Upload `batch-001.json` containing the newline-delimited records from `sample-data/efuse-events.json`.

Copy the **folder URL**. The managed connector expects a folder or shared-drive URL, not an individual file URL.

## 2. Create the Unity Catalog connection

In Databricks:

```text
Catalog
  → Create
    → Create a connection
      → Google Drive
```

Preferred authentication:

```text
OAuth U2M: Databricks-managed
```

If that option is not enabled in the workspace, use one of the other supported Google Drive authentication methods.

Use the connection name:

```text
lab_google_drive_connection
```

## 3. Create the managed ingestion pipeline

The managed Google Drive connector supports UI-based pipeline authoring.

Configure:

```text
Source:       lab_google_drive_connection
URL:          <Google Drive folder URL>
Entity type:  FILE
Format:       JSON
Destination:  bronze.efuse_events_managed
```

For the first run, keep the default schema-evolution mode:

```text
ADD_NEW_COLUMNS_WITH_TYPE_WIDENING
```

## 4. Run and validate

```sql
SELECT *
FROM bronze.efuse_events_managed;

DESCRIBE TABLE bronze.efuse_events_managed;
```

Record the row count and inferred schema.

## 5. Inspect the managed objects

Find:

- Unity Catalog connection
- ingestion pipeline
- destination streaming table
- pipeline event/monitoring information

Do not move to Lab 02 until you can explain which parts of ingestion were configured by you and which parts were operated by Databricks.
