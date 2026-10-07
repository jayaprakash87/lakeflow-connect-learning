# Managed connector vs standard/custom ingestion

We implement the same source and the same logical target twice.

## Path A — Managed

```text
Kafka
  ↓
Lakeflow Connect managed Kafka connector
  ↓
bronze.efuse_events_managed
```

We configure the connection, topic, destination, and ingestion behavior.

## Path B — Standard/custom

```text
Kafka
  ↓
Spark Structured Streaming
  ↓
Lakeflow Pipeline
  ↓
bronze.efuse_events_standard
```

We explicitly author the ingestion code and make more decisions ourselves.

## What we will compare

1. setup effort
2. code owned by us
3. connection/authentication model
4. offset/checkpoint state
5. failure recovery
6. schema changes
7. runtime management
8. monitoring
9. operational burden
10. flexibility and escape hatches

The purpose is not to prove that managed is always better. The purpose is to understand **where the abstraction boundary moves**.
