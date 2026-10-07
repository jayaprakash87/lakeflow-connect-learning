# Lab 01 — Create the Kafka connection

## What this step teaches

A managed connector separates **source credentials** from **pipeline code/configuration**.

Instead of embedding Kafka credentials in Spark options, Lakeflow Connect uses a **Unity Catalog Connection**.

## UI path

In Databricks:

```text
Catalog
  → Create
    → Create a connection
```

Configure:

```text
Connection name: lab_kafka_connection
Connection type: Kafka
Authentication: Username and Password
Bootstrap servers: <your Kafka bootstrap server>
Username: <Kafka username / API key>
Password: <Kafka password / API secret>
```

If your Kafka environment uses a supported service credential instead, use that authentication path.

A schema registry is optional for our first JSON lab and is not required.

## Why this matters

Without a managed connection, standard Spark code might contain options such as:

```python
.option("kafka.bootstrap.servers", "...")
.option("kafka.security.protocol", "SASL_SSL")
.option("kafka.sasl.mechanism", "PLAIN")
.option("kafka.sasl.jaas.config", "...")
```

With the managed connector, authentication belongs to a governed Unity Catalog object.

Conceptually:

```text
Pipeline
   │
   └── references → lab_kafka_connection
                         │
                         └── credentials + endpoint
```

A user with permission to use the connection can create ingestion pipelines without needing the raw credentials in the pipeline definition.

## Observation to record

After creating the connection, answer:

1. Where are the Kafka credentials stored?
2. Does the pipeline author need to know the password?
3. Which Unity Catalog privilege controls use of the connection?
4. Can the connection be reused by another ingestion pipeline?

Add your answers to the observation table in the Lab 01 README.
