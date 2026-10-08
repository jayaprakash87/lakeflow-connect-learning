# Lab 06 — Managed Kafka ingestion (advanced)

This lab revisits managed ingestion with a **continuous event stream** after the Google Drive and CDC concepts are understood.

## Why Kafka is later

The connector requires a Kafka endpoint reachable from Databricks serverless compute. That infrastructure requirement is useful later, but it is unnecessary friction for the first managed-ingestion experiment.

## Lab contents

1. `00-environment-plan.md`
2. `01-prerequisites.md`
3. `02-create-connection.md`
4. `03-create-pipeline.md`
5. `04-what-is-managed.md`
6. `05-validation-queries.sql`
7. `06-produce-test-events.md`
8. `07-deploy-with-bundle.md`

Supporting files:

```text
.env.example
requirements.txt
databricks.yml
kafka_managed_pipeline.yml
```

## Learning focus

Kafka makes several managed responsibilities especially visible:

- source authentication;
- consumer lifecycle;
- starting offsets;
- checkpointed progress;
- restart behavior;
- continuous serverless runtime;
- source metadata;
- append-only destination semantics.
