# Databricks Lakeflow Connect Learning Lab

A hands-on repository for understanding **managed ingestion** in Databricks by implementing the same ingestion problem at different abstraction levels.

## Core learning question

> What does Databricks manage when we move from custom/standard ingestion to a managed Lakeflow Connect connector?

The repo intentionally keeps the use case simple so we can focus on ownership boundaries: connection management, runtime, offsets/checkpoints, retries, recovery, schema handling, monitoring, and target-table semantics.

## Learning path

1. **Lab 01 — Managed Kafka ingestion**
   - Kafka topic `efuse-events`
   - Lakeflow Connect managed Kafka connector
   - Target: `bronze.efuse_events_managed`

2. **Lab 02 — Standard/custom Kafka ingestion**
   - Same Kafka topic
   - Spark Structured Streaming in a Lakeflow pipeline
   - Target: `bronze.efuse_events_standard`

3. **Lab 03 — Restart and recovery**
   - Stop/restart both implementations
   - Compare offset/state/recovery behavior

4. **Lab 04 — Schema evolution**
   - Add `temperature_c` to the source event
   - Observe how each implementation behaves

5. **Lab 05 — PostgreSQL CDC**
   - Repeat the managed-ingestion concept with database CDC

## Reference event

```json
{
  "vehicle_id": "V123",
  "fuse_id": "F17",
  "current_a": 21.4,
  "voltage_v": 12.1,
  "switch_state": 1,
  "event_ts": "2026-10-07T14:00:00Z"
}
```

## Comparison framework

Every lab should answer the same questions:

| Responsibility | Managed connector | Standard/custom |
|---|---|---|
| Define source | Us | Us |
| Define target | Us | Us |
| Write ingestion code | Minimal / none | Yes |
| Source protocol knowledge | Mostly Databricks | Us |
| Offset/checkpoint mechanics | Managed | Explicit Spark semantics |
| Retry/recovery | Managed | More ownership on us |
| Schema handling | Connector-specific managed behavior | Explicit design |
| Runtime | Managed/serverless where supported | Pipeline compute/runtime |
| Monitoring | Managed pipeline UX | Pipeline/Spark monitoring |
| Flexibility | Lower | Higher |
| Operational burden | Lower | Higher |

## Design principle

This is a learning lab, not a production template. CI/CD, Terraform, complex packaging, and enterprise deployment patterns are intentionally deferred until the ingestion concepts are clear.
