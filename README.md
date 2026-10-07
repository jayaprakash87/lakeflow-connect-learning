# Databricks Lakeflow Connect Learning Lab

A hands-on repository for understanding **managed ingestion** by implementing the same source with different levels of Databricks management.

## Core learning question

> What responsibility moves from us to Databricks when we move from a standard connector to a managed Lakeflow Connect connector?

## First executable comparison: Google Drive

We deliberately changed the first lab away from Kafka because a hosted Kafka service adds an unnecessary external-service/payment dependency.

Google Drive is a better first experiment because Databricks supports **both**:

- a managed Google Drive connector; and
- a standard Google Drive connector using Spark/SQL APIs.

Both can use the same Unity Catalog Google Drive connection and the same source folder. That gives us a controlled comparison without running Kafka infrastructure.

### Learning path

1. **Lab 01 — Managed Google Drive**
   - Same Google Drive folder
   - Managed Lakeflow Connect connector
   - Destination: `bronze.efuse_events_managed`

2. **Lab 02 — Standard Google Drive**
   - Same Google Drive folder
   - `read_files` / Auto Loader in a Lakeflow pipeline
   - Destination: `bronze.efuse_events_standard`

3. **Lab 03 — Incremental state and restart**
   - Add files after the first run
   - Restart both paths
   - Observe what is remembered and where

4. **Lab 04 — Schema evolution**
   - Add `temperature_c`
   - Compare managed vs explicit schema behavior

5. **Lab 05 — PostgreSQL CDC**
   - Extend the concept to database CDC

6. **Lab 06 — Managed Kafka**
   - Optional advanced streaming experiment

7. **Lab 07 — Standard Kafka**
   - Same Kafka source using Structured Streaming

## Reference eFuse data

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

| Responsibility | Managed connector | Standard connector |
|---|---|---|
| Connection/authentication | Governed connection | Governed connection |
| Source-specific ingestion definition | Configuration | Spark/SQL code |
| Incremental file discovery | Managed | Auto Loader/read_files semantics |
| Retry/recovery | More managed | More visible to us |
| Schema evolution | Connector configuration | Explicit pipeline options |
| Runtime | Managed/serverless | Lakeflow pipeline runtime |
| Monitoring | Managed pipeline | Pipeline/Spark monitoring |
| Flexibility | Lower | Higher |
| Operational burden | Lower | Higher |

## Design principle

This is a controlled learning lab, not a production template. We intentionally postpone Terraform, CI/CD, complex packaging, and production networking until the ingestion abstraction is understood.
