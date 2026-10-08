# Lab 06 — Create the Kafka Unity Catalog connection

## Objective

Separate credentials/network identity from the ingestion pipeline definition.

---

# Step 1 — Open connection creation

In Databricks:

```text
Catalog
  → Create
  → Create a connection
```

---

# Step 2 — Connection basics

Use:

```text
Connection name:
lab_kafka_connection

Connection type:
Kafka
```

---

# Step 3 — Authentication

Choose the method that matches your Kafka environment.

## Option A — Username and Password

Use when your Kafka cluster authenticates using SASL/PLAIN or SASL/SCRAM.

Enter:

```text
Bootstrap servers: <broker-host:port>
Username:          <Kafka username / API key>
Password:          <Kafka password / API secret>
```

## Option B — Service Credential

Choose:

```text
Auth type:
Service Credential
```

Then select/create the service credential and enter the bootstrap servers.

---

# Step 4 — Schema Registry

Leave schema registry blank for the first experiment.

Our messages contain raw JSON, and we intentionally ingest raw Kafka key/value first.

We will discuss deserialization later.

---

# Step 5 — Create connection

Click:

```text
Create connection
```

After creation, confirm you can see:

```text
lab_kafka_connection
```

in Catalog Explorer.

---

# Step 6 — Understand the security boundary

The pipeline definition will contain only:

```text
connection_name = lab_kafka_connection
```

It will **not** contain:

- broker password;
- API secret;
- SASL JAAS string.

A user with `USE CONNECTION` can build a pipeline without receiving the raw source password.

That is one of the core managed-ingestion governance benefits.

---

# Record these observations

| Question | Observation |
|---|---|
| Where are bootstrap servers stored? | |
| Where are credentials stored? | |
| Does YAML contain the Kafka password? | |
| Which privilege allows pipeline use of the connection? | |
| Can the same connection be reused? | |
