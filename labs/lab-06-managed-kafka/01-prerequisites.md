# Lab 06 — Prerequisites and environment

## Goal

Create the smallest possible Kafka environment that lets us observe what a **managed Lakeflow Connect Kafka connector** does for us.

## Recommended learning setup

For the first lab, use a small external Kafka service such as **Confluent Cloud** rather than operating Kafka ourselves.

Why:

- we want to study **Databricks managed ingestion**, not Kafka administration;
- a hosted Kafka endpoint gives us bootstrap servers and credentials quickly;
- later, if useful, we can repeat the lab with another Kafka implementation.

The source platform is intentionally not the learning target.

## Databricks requirements

Before creating the managed Kafka pipeline, verify:

- Unity Catalog is enabled.
- Serverless compute is enabled.
- The Lakeflow Connect Kafka preview is enabled in the workspace.
- The user creating a new connection has the required Unity Catalog privilege to create connections, or an admin creates the connection first.
- The Databricks serverless network can reach the Kafka brokers.

> The managed Kafka connector is currently a Beta feature, so availability depends on workspace settings.

## Kafka requirements

Create:

- one Kafka cluster;
- one topic named `efuse-events`;
- credentials with permission to read the topic;
- bootstrap server address.

For this lab, one partition is enough. We are not testing Kafka scaling.

## Databricks objects we expect

```text
Kafka cluster
   ↓
Unity Catalog Connection
   ↓
Lakeflow Connect ingestion pipeline
   ↓
Streaming table
   ↓
bronze.efuse_events_managed
```

The purpose of the lab is to inspect these objects and understand which responsibilities are no longer implemented in our application code.

## Do not add yet

Do not add:

- complex schemas;
- transformations;
- multiple topics;
- fanout;
- production security architecture;
- CI/CD;
- Terraform.

Those will hide the managed-ingestion concept we are trying to observe.
