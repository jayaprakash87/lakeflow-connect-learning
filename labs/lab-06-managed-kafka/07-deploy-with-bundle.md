# Lab 06 — Deploy the managed Kafka pipeline

## Prerequisites

Before running the bundle:

- Databricks CLI installed
- CLI authenticated to the correct workspace
- Kafka Beta preview enabled
- `lab_kafka_connection` exists
- target catalog/schema exists
- required UC privileges granted

---

# Step 1 — Review bundle variables

Open:

```text
databricks.yml
```

Defaults:

```text
connection_name = lab_kafka_connection
dest_catalog     = main
dest_schema      = bronze
```

Change the defaults if your learning workspace uses another catalog/schema.

Do not put Kafka secrets in this file.

---

# Step 2 — Validate the bundle

From:

```text
labs/lab-06-managed-kafka
```

run:

```bash
databricks bundle validate -t dev
```

Do not deploy if validation fails.

Fix configuration first.

---

# Step 3 — Deploy

Run:

```bash
databricks bundle deploy -t dev
```

The deployment creates/updates:

```text
lakeflow-managed-kafka-efuse
```

---

# Step 4 — Start the continuous pipeline

After deployment, open:

```text
Jobs & pipelines
  → lakeflow-managed-kafka-efuse
```

Start the pipeline if deployment did not already start it.

Verify:

```text
serverless = true
continuous = true
channel    = PREVIEW
```

---

# Step 5 — Validate ingestion

Run the queries in:

```text
05-validation-queries.sql
```

You should see:

```text
key
value
_kafka_metadata
```

and offsets increasing as new events are produced.

---

# Step 6 — Do not Full Refresh before the restart experiment

The next lab step tests checkpoint behavior.

Use:

```text
normal stop / normal start
```

Do not:

```text
Full refresh
Reset state
Delete destination/checkpoint state
```

because that would intentionally change the starting-state semantics.
