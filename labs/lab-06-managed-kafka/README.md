# Lab 06 — Managed Kafka ingestion

## Objective

Move from scheduled/file-based ingestion to a **continuous event stream** and understand what Lakeflow Connect manages for Kafka.

The architecture is:

```text
Producer
   ↓
Kafka topic: efuse-events
   ↓
Unity Catalog Kafka connection
   ↓
Managed Lakeflow Connect Kafka pipeline
   ↓
Streaming table
   ↓
bronze.efuse_events_managed
```

This lab focuses only on the **managed Kafka connector**. Lab 07 will rebuild the same source using explicit Spark Structured Streaming.

---

# What you should learn

By the end of Lab 06 you should be able to explain:

1. why Kafka ingestion is continuous rather than scheduled file discovery;
2. what `starting_offset` means;
3. why `starting_offset` matters only when no checkpoint exists;
4. how Kafka partition/offset metadata proves exactly what was consumed;
5. why a normal restart does not reread the topic from the beginning;
6. which responsibilities remain with Kafka and which move to Databricks;
7. why the managed connector produces an append-only streaming table;
8. why we can ingest raw key/value first and parse JSON downstream.

---

# Important product status

The managed Kafka connector is currently **Beta**.

A workspace admin must enable:

```text
Lakeflow Connect for Kafka
```

from the Databricks **Previews** page.

Also note:

> UI-based pipeline authoring is not supported for the Kafka connector in Beta.

So this lab uses a **Declarative Automation Bundle** as the primary path.

Databricks also supports a notebook-based creation path, but the bundle is better for this repository because the pipeline definition stays version controlled.

---

# Lab structure

Follow these files in order:

```text
00-environment-plan.md
01-prerequisites.md
02-create-connection.md
03-create-pipeline.md
04-what-is-managed.md
05-validation-queries.sql
06-produce-test-events.md
07-deploy-with-bundle.md
08-restart-offset-experiment.md
09-json-transformer.md
```

Supporting files:

```text
.env.example
requirements.txt
databricks.yml
kafka_managed_pipeline.yml
kafka_efuse_producer.py
```

---

# Controlled experiment design

Keep these constant:

```text
Kafka cluster
Topic
Produced messages
Destination catalog/schema
Message format
```

Lab 06 changes only:

```text
ingestion abstraction = managed Kafka connector
```

Lab 07 will use:

```text
ingestion abstraction = Spark Structured Streaming
```

That lets us compare management boundaries rather than different source systems.

---

# Completion checklist

- [ ] Kafka endpoint reachable from Databricks serverless compute
- [ ] `efuse-events` topic exists
- [ ] test events successfully produced
- [ ] Kafka Beta preview enabled
- [ ] Unity Catalog Kafka connection created
- [ ] managed pipeline bundle validated
- [ ] managed pipeline bundle deployed
- [ ] pipeline running continuously
- [ ] destination streaming table created
- [ ] Kafka source metadata visible
- [ ] restart/offset experiment completed
- [ ] JSON transformer experiment understood

---

# Final responsibility comparison

| Concern | Kafka/source side | Managed Lakeflow Connect |
|---|---|---|
| Brokers | Kafka | |
| Topic creation | Kafka | |
| Partitions | Kafka | |
| Retention | Kafka | |
| Producer semantics | Kafka | |
| ACLs | Kafka | |
| UC connection | | Databricks |
| Consumer lifecycle | | Databricks |
| Streaming runtime | | Databricks |
| Checkpoint/progress state | | Databricks |
| Retry/recovery | | Databricks |
| Destination table | | Databricks |
| Kafka metadata exposure | | Configured in connector |
| Business transformation | Downstream responsibility | Downstream responsibility |

The key sentence is:

> Kafka still owns the event platform; Lakeflow Connect manages the consumer-side ingestion machinery into Databricks.
