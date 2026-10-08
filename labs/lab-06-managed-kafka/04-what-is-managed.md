# Lab 06 — What exactly became managed?

After the pipeline works, do not immediately move to Lab 02.

First compare what we **did not have to build**.

## Responsibility boundary

| Concern | Did we implement it? | Who owns it now? | Evidence from the lab |
|---|---:|---|---|
| Kafka connection lifecycle | No/Minimal | Databricks + source configuration | |
| Raw credentials in pipeline code | No | Unity Catalog connection | |
| Structured Streaming read code | No | Managed connector | |
| Consumer lifecycle | No | Managed connector | |
| Starting offset configuration | Configure intent only | Managed connector/runtime | |
| Ongoing checkpoint/state | No direct implementation | Managed connector/runtime | |
| Restart lifecycle | No custom restart code | Managed pipeline | |
| Serverless ingestion runtime | No cluster provisioning | Databricks | |
| Destination streaming table creation | Declarative/configured | Lakeflow pipeline | |
| Monitoring surface | No custom dashboard for basic health | Databricks pipeline UI | |
| Business transformation logic | Not part of this lab | Still ours downstream | |

## The key distinction

Managed does **not** mean that Kafka itself disappears.

Kafka still owns:

- brokers;
- topics;
- partitions;
- retention;
- producer semantics;
- source-side authentication and ACLs.

Databricks manages the **consumer-side ingestion machinery into Databricks**.

So the boundary is:

```text
Kafka responsibilities            Databricks managed ingestion
----------------------            -----------------------------
broker availability        →      connection consumption
topic/partition model      →      consumer lifecycle
message retention          →      ingestion state
producer behavior          →      retries/recovery
ACLs                        →      destination writes
                                   pipeline runtime
                                   monitoring
```

That distinction is the actual learning objective of Lab 06.
