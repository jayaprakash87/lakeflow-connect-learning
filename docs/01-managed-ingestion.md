# Managed ingestion: the concept

A **managed ingestion layer** lets us declare the ingestion intent while the platform owns much of the recurring operational machinery.

## We define

- source
- authentication/connection
- objects/topics/tables to ingest
- destination
- schedule or continuous mode
- connector-specific options

## The platform manages more of

- incremental state
- offsets, cursors, or CDC positions
- retries and recovery
- source-specific protocol behavior
- runtime lifecycle
- destination writes
- monitoring
- some schema evolution behavior

The important distinction is not "code versus no code." It is **responsibility ownership**.

## Imperative model

```text
connect
authenticate
read state
read new data
handle retries
write target
update state
recover after failure
```

## Managed/declarative model

```text
Source: Kafka
Topic: efuse-events
Target: bronze.efuse_events_managed
Mode: continuous
```

The connector owns much more of the "how."

## Managed does not mean zero configuration

Managed ingestion still requires architectural choices. It simply moves generic ingestion mechanics from application code into the platform.
