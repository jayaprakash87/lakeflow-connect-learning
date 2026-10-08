# Lab 06 — Prerequisites

## Databricks requirements

Before doing anything else, verify:

- Unity Catalog is enabled.
- Serverless compute is enabled.
- **Lakeflow Connect for Kafka** is enabled under Previews.
- You have `CREATE CONNECTION` on the metastore, or an admin creates the connection.
- You have `USE CONNECTION` on an existing Kafka connection.
- You have `USE CATALOG` on the target catalog.
- You have `USE SCHEMA` and `CREATE TABLE` on the target schema.
- Databricks serverless networking can reach the Kafka brokers.

The connector is currently Beta.

---

# Kafka requirements

You need:

```text
bootstrap server(s)
topic = efuse-events
credentials
network reachability
```

The connector supports two Databricks-side authentication approaches:

1. **Username and Password**
   - SASL/PLAIN
   - SASL/SCRAM

2. **Service Credential**
   - use an existing Unity Catalog service credential

A schema registry is optional and is not required for the first raw JSON experiment.

---

# Verify the source before involving Databricks

Before creating the Databricks connection, prove that your Kafka source works.

You should be able to:

1. produce a test record;
2. see that the topic exists;
3. confirm the producer receives an offset.

The included producer prints:

```text
topic
partition
offset
```

for each successfully delivered message.

Do not proceed until the source itself works.

---

# Expected Databricks architecture

```text
Kafka broker
   ↓
UC connection
   ↓
managed continuous ingestion pipeline
   ↓
streaming table
```

There is no separate ingestion gateway like the PostgreSQL CDC lab.

That distinction matters:

```text
PostgreSQL CDC → gateway + staging + ingestion pipeline
Kafka          → continuous managed ingestion pipeline
```
