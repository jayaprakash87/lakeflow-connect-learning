# Lab 06 — What exactly is managed?

Do this review only after the pipeline is running.

## Responsibility boundary

| Concern | Kafka/source | Databricks managed connector |
|---|---:|---:|
| Broker availability | ✓ | |
| Topic creation | ✓ | |
| Partition count | ✓ | |
| Retention | ✓ | |
| Producer | ✓ | |
| ACLs | ✓ | |
| Unity Catalog connection | | ✓ |
| Consumer creation/lifecycle | | ✓ |
| Continuous serverless runtime | | ✓ |
| Source progress/checkpoint | | ✓ |
| Normal restart/resume | | ✓ |
| Retry/recovery | | ✓ |
| Destination streaming table | | ✓ |
| Source metadata struct | | ✓ |
| Business parsing | downstream | downstream |

---

# The biggest misconception to avoid

Do not say:

```text
Lakeflow Connect replaces Kafka.
```

It does not.

The correct statement is:

> Kafka remains the event backbone. Lakeflow Connect replaces much of the custom consumer-side ingestion plumbing needed to land those Kafka events into Databricks.

---

# What we did NOT write

No code for:

```text
spark.readStream.format("kafka")
consumer group lifecycle
writeStream
checkpointLocation
retry loops
offset persistence
cluster provisioning
destination table writer
```

But we still made architectural choices about:

```text
topic
starting offset
metadata exposure
destination
continuous runtime
deserialization strategy
```

Managed means **less implementation ownership**, not zero design responsibility.
