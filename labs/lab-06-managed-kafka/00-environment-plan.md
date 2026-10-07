# Lab 06 — Environment plan

We need two systems:

```text
Confluent Cloud Kafka
        ↓
Databricks Lakeflow Connect
```

## Why Confluent Cloud for this lab

We are testing the **Databricks ingestion abstraction**, not Kafka administration.

A hosted Kafka service gives us:

- bootstrap servers;
- SASL credentials;
- a real Kafka topic;
- no broker installation or maintenance.

## Minimal setup

### Kafka side

Create:

```text
Cluster: lakeflow-learning
Topic: efuse-events
Partitions: 1
Credentials: API key + secret
```

One partition is deliberate. Partition scaling is not part of this experiment.

### Databricks side

Create:

```text
Connection: lab_kafka_connection
Catalog/schema: choose an existing learning catalog + bronze schema
Target table: bronze.efuse_events_managed
```

## Information we need before pipeline creation

Record these values locally; never commit secrets:

```text
KAFKA_BOOTSTRAP_SERVERS=
KAFKA_API_KEY=
KAFKA_API_SECRET=
```

Commit only placeholders or an `.env.example`.

## Security rule

Never place the API secret in:

- README files;
- notebooks committed to Git;
- screenshots;
- source code.

The secret should be entered into the Kafka/Unity Catalog connection configuration only.
