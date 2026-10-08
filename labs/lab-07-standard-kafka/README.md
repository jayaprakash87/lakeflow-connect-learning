# Lab 07 — Standard Kafka with Lakeflow ETL + Structured Streaming

## Objective

Ingest the **same `efuse-events` Kafka topic** as Lab 06, but this time use the standard Kafka source through a normal **ETL pipeline**.

This is the direct comparison:

```text
Lab 06
Kafka
  ↓
Managed Kafka connector
  ↓
Managed continuous ingestion pipeline
  ↓
bronze.efuse_events_managed

Lab 07
Kafka
  ↓
spark.readStream.format("kafka")
  ↓
Lakeflow ETL pipeline
  ↓
bronze.efuse_events_standard
```

The topic, message format, and Bronze contract stay the same. Only the ingestion abstraction changes.

---

# What you should learn

By the end of Lab 07 you should be able to explain:

1. how to create a Kafka streaming table explicitly with Structured Streaming;
2. which Kafka options we now configure ourselves;
3. why `startingOffsets` is only applied when no checkpoint/progress state exists;
4. how Lakeflow still manages streaming-table execution state even though the Kafka source is now explicit;
5. how authentication differs from the managed connector;
6. what the standard path exposes that the managed connector hides;
7. why standard does **not** mean unmanaged;
8. how to run Kafka ingestion continuously in a production-style setup.

---

# Critical controlled-experiment rule

Lab 06 and Lab 07 use the same Bronze contract:

```text
key               BINARY
value             BINARY
_kafka_metadata   STRUCT
```

Do **not** parse the eFuse JSON during the primary ingestion experiment.

Otherwise we would be comparing:

```text
ingestion abstraction
+
transformation logic
```

at the same time.

---

# Step 1 — Create the correct pipeline type

In Databricks:

```text
Jobs & pipelines
  → Create new
  → ETL pipeline
```

Do **not** select **Ingestion pipeline**.

Why:

- **Ingestion pipeline** = managed connector path from Lab 06
- **ETL pipeline** = code-first Lakeflow pipeline where we explicitly define the Kafka stream

Name it:

```text
lab-standard-kafka-efuse
```

---

# Step 2 — Set the Default location

When the Lakeflow Pipelines Editor opens, configure:

```text
Default catalog: <your learning catalog>
Default schema:  bronze
```

For example:

```text
main.bronze
```

or:

```text
workspace.bronze
```

Use the same catalog/schema pattern as Lab 06 where possible.

Save the pipeline settings.

---

# Step 3 — Keep the source file in Python

Unlike Lab 02, do **not** switch the source file to SQL for the primary experiment.

Keep the default transformation file as Python and rename it:

```text
kafka_to_bronze.py
```

Why Python?

Because this lab is specifically meant to expose:

```python
spark.readStream
    .format("kafka")
    .option(...)
```

That makes the standard Structured Streaming mechanics explicit.

Databricks also supports SQL through `read_kafka()`; we cover that later as an alternative.

---

# Step 4 — Decide authentication BEFORE writing code

This is a major difference from Lab 06.

## Lab 06 managed connector

Authentication lived in:

```text
Unity Catalog Kafka Connection
```

The pipeline referenced only:

```text
lab_kafka_connection
```

## Lab 07 standard Structured Streaming

The normal Kafka source does **not** automatically consume the managed Kafka UC connection object.

Instead, use one of these:

### Option A — Unity Catalog service credential

Recommended for supported cloud-managed Kafka services such as:

- Amazon MSK
- Azure Event Hubs using Kafka protocol
- Google Cloud Managed Kafka

Configure:

```python
.option("databricks.serviceCredential", "<service-credential-name>")
```

Databricks recommends service credentials for cloud-managed Kafka where supported.

### Option B — SASL username/password

For generic Kafka using SASL/PLAIN or SASL/SCRAM:

- store credentials in a Databricks secret scope;
- retrieve them at runtime;
- never hardcode them in GitHub.

Example pattern:

```python
username = dbutils.secrets.get(scope="kafka-lab", key="username")
password = dbutils.secrets.get(scope="kafka-lab", key="password")
```

Then use them to construct the Kafka SASL options.

For the first comparison, use whichever authentication mechanism matches the Kafka environment already used in Lab 06.

---

# Step 5 — Parameterize non-secret settings

In pipeline settings, add configuration values such as:

```text
kafka.bootstrap_servers = <broker-host:port>
kafka.topic             = efuse-events
kafka.auth_mode         = service_credential
```

If using a service credential, also add:

```text
kafka.service_credential = <service-credential-name>
```

If using SASL, secrets stay in the secret scope rather than plain pipeline parameters.

The Python code reads configuration using:

```python
spark.conf.get("kafka.bootstrap_servers")
```

This separates:

```text
code
from
environment-specific configuration
```

---

# Step 6 — Use the Lab 07 Python source

Use:

```text
labs/lab-07-standard-kafka/kafka_to_bronze.py
```

The core pattern is:

```python
from pyspark import pipelines as dp
from pyspark.sql import functions as F

@dp.table(name="efuse_events_standard")
def efuse_events_standard():
    raw = (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", bootstrap_servers)
        .option("subscribe", topic)
        .option("startingOffsets", "earliest")
        .option("includeHeaders", "true")
        .load()
    )

    return raw.select(
        F.col("key"),
        F.col("value"),
        F.struct(
            F.col("topic"),
            F.col("partition"),
            F.col("offset"),
            F.col("timestamp"),
            F.col("timestampType"),
            F.col("headers"),
        ).alias("_kafka_metadata"),
    )
```

Because the function returns a **streaming DataFrame**, `@dp.table` creates a streaming table.

Databricks recommends Lakeflow pipelines for new Structured Streaming ingestion workloads, and Kafka sources are supported directly in pipeline code. 

---

# Step 7 — Configure starting offsets

For this controlled comparison, use:

```text
startingOffsets = earliest
```

This mirrors Lab 06's:

```text
starting_offset = earliest
```

Important:

> `startingOffsets` applies when a new streaming query has no existing checkpoint/progress state.

Once the Lakeflow streaming table has state, normal reruns resume from that state rather than reapplying `earliest`.

This is the same conceptual rule you observed in Lab 06.

---

# Step 8 — Run the pipeline first in Triggered mode

For the first validation, keep the ETL pipeline in its default:

```text
Pipeline mode = Triggered
```

Run the pipeline once.

Triggered mode:

```text
process all currently available Kafka records
→ update the streaming table
→ stop
```

This is useful for learning because the run has a clear start and end.

Validate:

```sql
SELECT COUNT(*)
FROM <catalog>.bronze.efuse_events_standard;
```

Then inspect offsets with `validation.sql`.

---

# Step 9 — Compare offsets with Lab 06

Run:

```sql
SELECT
  _kafka_metadata.partition,
  MIN(_kafka_metadata.offset) AS min_offset,
  MAX(_kafka_metadata.offset) AS max_offset,
  COUNT(*) AS records
FROM <catalog>.bronze.efuse_events_standard
GROUP BY _kafka_metadata.partition;
```

Compare with:

```text
efuse_events_managed
```

If both began from earliest and consumed the same topic history, their offset ranges should be comparable.

Do not assume identical row counts if the pipelines were started at different times and Kafka retention or new message production differs.

---

# Step 10 — Restart/state experiment

Now test the same checkpoint concept as Lab 06.

## 10.1 Run Lab 07 once

Record the maximum Kafka offset.

## 10.2 Do not Full Refresh

Leave the streaming-table state intact.

## 10.3 Produce five new Kafka messages

Use the Lab 06 producer.

## 10.4 Run Lab 07 again

Expected:

```text
old offsets are not duplicated
new offsets are consumed
```

This proves:

```text
standard Structured Streaming is also stateful
```

The difference is not:

```text
managed = checkpointed
standard = not checkpointed
```

Both preserve progress.

The difference is:

```text
Managed:
Kafka consumer implementation is largely hidden.

Standard:
Kafka read configuration is authored by us,
while Lakeflow still manages the streaming-table execution state.
```

---

# Step 11 — Move to continuous execution

After the triggered experiment is understood, configure the pipeline for continuous ingestion.

There are two concepts:

## Built-in pipeline Continuous mode

In pipeline settings:

```text
Pipeline mode → Continuous
```

A continuous pipeline keeps processing new Kafka data as it arrives.

## Recommended production pattern

Databricks now recommends wrapping the pipeline in a **continuous Lakeflow Job** rather than relying on the pipeline's built-in continuous mode for new production pipelines.

In that pattern:

```text
Pipeline mode = Triggered
Continuous Job
    ↓
Pipeline task
    ↓
runs continuously
```

The job schedule determines execution mode and overrides the pipeline's own mode.

For this learning lab, using the pipeline's built-in Continuous mode is acceptable because it makes the concept visible. For production architecture, prefer the continuous-job pattern.

---

# Step 12 — Observe Kafka lag metrics

Standard Structured Streaming exposes Kafka backlog metrics such as:

```text
avgOffsetsBehindLatest
maxOffsetsBehindLatest
minOffsetsBehindLatest
```

These show how far the consumer is behind the latest Kafka offsets.

This is an important operational capability that becomes more visible in the standard path.

Inspect pipeline streaming metrics after producing records faster than the consumer processes them.

---

# Step 13 — SQL alternative

Python is the primary lab path, but the same standard Kafka source can be written in SQL using `read_kafka()`.

Example:

```sql
CREATE OR REFRESH STREAMING TABLE efuse_events_standard_sql
AS
SELECT
  key,
  value,
  named_struct(
    'topic', topic,
    'partition', partition,
    'offset', offset,
    'timestamp', timestamp,
    'timestampType', timestampType,
    'headers', headers
  ) AS _kafka_metadata
FROM STREAM read_kafka(
  bootstrapServers => '<broker-host:port>',
  subscribe => 'efuse-events',
  startingOffsets => 'earliest'
);
```

If using a Unity Catalog service credential, SQL supports:

```text
serviceCredential => '<service-credential-name>'
```

This reinforces another concept:

> Standard connector does not mean Python-only. It means you explicitly define the Kafka read using Spark/SQL APIs.

---

# Step 14 — Do not manually set checkpointLocation inside the pipeline

In standalone Structured Streaming code you often see:

```python
.writeStream
.option("checkpointLocation", "...")
```

Do **not** add that pattern to this Lakeflow pipeline.

Why?

The streaming table is managed by Lakeflow.

We define:

```python
@dp.table
def efuse_events_standard():
    return spark.readStream...
```

Lakeflow owns the execution/checkpoint lifecycle for that streaming table.

This is a critical nuance:

> Standard Kafka gives us explicit source configuration, but Lakeflow still manages pipeline orchestration and streaming-table state.

---

# Step 15 — Full refresh warning

Do not use Full Refresh during the restart/state experiment.

Normal update:

```text
existing progress
→ consume only newer offsets
```

Full refresh/reset:

```text
rebuild streaming state
→ source starting behavior can be reconsidered
```

Those are different experiments.

---

# Final managed vs standard comparison

| Concern | Lab 06 managed Kafka | Lab 07 standard Kafka |
|---|---|---|
| Pipeline entry point | Managed connector definition | ETL pipeline |
| Kafka read code | None | `spark.readStream.format("kafka")` |
| Topic selection | Connector YAML | Spark option |
| Starting offset | Connector option | Spark option |
| Authentication | UC Kafka connection | Service credential or explicit SASL |
| Consumer lifecycle | Hidden/managed | Spark/Lakeflow runtime |
| Checkpoint path manually supplied | No | No inside Lakeflow |
| Progress state | Managed | Managed by Lakeflow streaming table |
| Kafka metadata | Connector metadata struct | We explicitly construct it |
| Lag metrics | Managed connector monitoring | Structured Streaming metrics |
| Transformation flexibility | Lower | Higher |
| Source-specific code ownership | Very low | Higher |
| Continuous ingestion | Built into managed connector | Pipeline/job execution choice |

---

# The core Lab 07 lesson

Do not summarize the difference as:

```text
managed = automatic
standard = manual
```

That is too simplistic.

The more accurate model is:

```text
Managed Kafka
    ↓
Databricks owns:
connection consumption
Kafka source configuration abstraction
consumer lifecycle
streaming runtime
checkpoint/progress
destination writer

Standard Kafka in Lakeflow
    ↓
We own:
Kafka source options
authentication integration
metadata shaping
source-side code

Lakeflow still owns:
pipeline orchestration
streaming-table execution
progress/checkpoint lifecycle
destination table lifecycle
monitoring
```

So the abstraction boundary moved — it did not disappear.
