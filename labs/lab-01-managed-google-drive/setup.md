# Managed Google Drive — execution steps

## 1. Prepare the source folder

In Google Drive, create a folder named:

```text
lakeflow-connect-learning
```

Upload a file named `batch-001.json` containing newline-delimited JSON records from `sample-data/efuse-events.json`.

Copy the Google Drive folder URL.

## 2. Create the Unity Catalog connection

In Databricks, create a **Google Drive** connection.

Preferred authentication for this lab:

```text
OAuth U2M: Databricks-managed
```

This avoids creating a Google Cloud project or registering a custom OAuth application.

## 3. Create managed ingestion

Create a Lakeflow Connect managed Google Drive ingestion pipeline using:

```text
Source:       Google Drive connection
Entity:       FILE
URL:          <Google Drive folder URL>
Format:       JSON
Destination:  bronze.efuse_events_managed
```

Use the default managed schema-evolution behavior for the first run. We will change it deliberately in Lab 04.

## 4. Run and validate

Query:

```sql
SELECT *
FROM bronze.efuse_events_managed;

DESCRIBE TABLE bronze.efuse_events_managed;
```

Record the row count and target schema.

## 5. Inspect the managed objects

Find:

- Unity Catalog connection;
- ingestion pipeline;
- destination streaming table;
- pipeline event/monitoring information.

Do not move to Lab 02 until you can explain which of these objects replaces logic that would otherwise live in Spark/SQL code.
