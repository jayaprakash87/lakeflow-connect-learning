# Lab 06 — Environment plan

We need:

```text
Any Kafka endpoint reachable from Databricks serverless compute
        ↓
Databricks Lakeflow Connect
```

## Provider-neutral setup

Do **not** create a paid Kafka account solely for this lab.

Use any Kafka environment you already have access to, for example:

- an existing enterprise Kafka cluster;
- an existing Azure Event Hubs namespace using its Kafka-compatible endpoint;
- another hosted Kafka service already available to you.

A Kafka broker running only on a laptop is not enough unless Databricks serverless networking can reach it.

## Minimal Kafka setup

```text
Topic: efuse-events
Partitions: 1
Credentials: source-appropriate Kafka credentials
```

One partition is deliberate. Partition scaling is not part of this experiment.

## Databricks side

```text
Connection: lab_kafka_connection
Catalog/schema: learning catalog + bronze
Target: bronze.efuse_events_managed
```

## Information needed

The exact credential names depend on the Kafka provider. For the included SASL/PLAIN producer example:

```text
KAFKA_BOOTSTRAP_SERVERS=
KAFKA_API_KEY=
KAFKA_API_SECRET=
```

Never commit real credentials.
