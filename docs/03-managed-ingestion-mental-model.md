# Managed ingestion mental model

Use this model whenever evaluating an ingestion technology.

## Layer 1 — Source

The source system still owns its native responsibilities.

Examples:

- Kafka: brokers, topics, partitions, retention
- PostgreSQL: WAL, source database availability
- Salesforce: API availability, permissions, rate limits

## Layer 2 — Ingestion control plane

Defines **what should happen**:

- connection
- source object/topic
- destination
- schedule/continuous mode
- connector options

## Layer 3 — Ingestion data plane

Performs the recurring mechanics:

- read new data
- maintain progress/state
- retry
- recover
- run compute
- write destination

With a managed connector, Databricks owns much more of this layer.

## Layer 4 — Destination

The output lands directly in Databricks-governed tables, typically streaming tables for managed streaming connectors.

## Layer 5 — Business processing

Managed ingestion does not remove the need for domain logic:

```text
bronze.efuse_events_managed
        ↓
decode / validate / normalize
        ↓
silver.efuse_measurements
        ↓
aggregate / KPI
        ↓
gold.efuse_health
```

The managed connector reduces generic ingestion plumbing. It does not replace business transformations.
