# Lab 06 — Create the managed Kafka pipeline

## Important UI difference

Unlike Google Drive and PostgreSQL, the managed Kafka connector currently does **not** support UI-based pipeline authoring in Beta.

Do not go to:

```text
Jobs & pipelines
  → Create
  → Ingestion pipeline
```

expecting a Kafka wizard.

Instead use:

```text
Declarative Automation Bundle
```

for this lab.

---

# Pipeline architecture

```text
Kafka: efuse-events
        ↓
lab_kafka_connection
        ↓
lab-managed-kafka-efuse
        ↓
<catalog>.bronze.efuse_events_managed
```

---

# Step 1 — Review the bundle

The lab contains:

```text
databricks.yml
kafka_managed_pipeline.yml
```

The important pipeline definition is:

```yaml
resources:
  pipelines:
    managed_kafka_efuse:
      name: lakeflow-managed-kafka-efuse
      serverless: true
      continuous: true
      channel: PREVIEW
      catalog: ${var.dest_catalog}
      target: ${var.dest_schema}
      ingestion_definition:
        connection_name: ${var.connection_name}
        objects:
          - table:
              source_table: N/A
              destination_catalog: ${var.dest_catalog}
              destination_schema: ${var.dest_schema}
              destination_table: efuse_events_managed
              table_configuration:
                source_metadata_column: _kafka_metadata
              connector_options:
                kafka_options:
                  topics:
                    - efuse-events
                  starting_offset: earliest
```

---

# Step 2 — Understand each setting

## `serverless: true`

Databricks operates the ingestion compute.

## `continuous: true`

The pipeline stays active and consumes Kafka as events arrive.

This is different from the Google Drive experiments, where we manually triggered pipeline updates.

## `channel: PREVIEW`

Required for this Beta connector.

## `connection_name`

References the Unity Catalog connection.

No raw credentials appear in YAML.

## `topics`

Subscribes to:

```text
efuse-events
```

## `starting_offset: earliest`

When **no checkpoint exists**, consume from the earliest retained message.

Default behavior would otherwise be `latest`.

This setting is relevant only on the first state initialization.

## `source_metadata_column`

Adds:

```text
_kafka_metadata
```

containing:

- topic
- partition
- offset
- timestamp
- timestampType
- headers

We enable this specifically so we can prove restart and offset behavior.

---

# Step 3 — Raw destination schema

Without a transformer, Kafka message data lands as:

```text
key   BINARY
value BINARY
```

plus our metadata struct.

That is deliberate.

Lab 06 first studies ingestion mechanics.

JSON parsing is a separate concern and is tested later in `09-json-transformer.md`.

---

# Step 4 — Deploy

Follow:

```text
07-deploy-with-bundle.md
```

After deployment, find:

```text
Jobs & pipelines
  → lakeflow-managed-kafka-efuse
```

and verify that it is continuous/serverless.

---

# Success criterion

Once the test producer sends records, this query returns rows:

```sql
SELECT *
FROM <catalog>.bronze.efuse_events_managed;
```

and the Kafka offsets are visible in:

```text
_kafka_metadata.offset
```
