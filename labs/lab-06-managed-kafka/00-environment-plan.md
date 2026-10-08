# Lab 06 — Environment plan

## Goal

Use **any Kafka-compatible endpoint already available to you**.

Do not buy or create a paid Kafka service solely for this lab.

Possible sources:

- an existing enterprise Kafka cluster;
- an existing Azure Event Hubs namespace using the Kafka-compatible endpoint;
- another hosted Kafka service you already have access to.

A Kafka broker running only on your laptop is not sufficient unless Databricks serverless networking can reach it.

---

# Minimal source setup

Create or identify:

```text
Topic:      efuse-events
Partitions: 1
```

One partition is deliberate so offsets are easy to inspect.

For the lab you need:

```text
bootstrap servers
authentication method
read permission for Databricks
write permission for your test producer
```

The included producer assumes:

```text
SASL_SSL
SASL/PLAIN
username/API key
password/API secret
```

If your provider uses SCRAM or another supported method, adapt the producer-side settings accordingly.

---

# Databricks objects

We will create:

```text
Connection:
lab_kafka_connection

Pipeline:
lab-managed-kafka-efuse

Destination:
<catalog>.bronze.efuse_events_managed
```

The destination is a streaming table.

---

# Security

Never commit:

- broker passwords;
- API secrets;
- private endpoints;
- service credentials.

Use:

```text
.env.example
```

only as a placeholder template.

The actual Kafka credentials belong in:

```text
Unity Catalog connection
```

not in pipeline YAML.
