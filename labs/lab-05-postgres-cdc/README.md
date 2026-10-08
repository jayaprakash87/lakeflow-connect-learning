# Lab 05 — PostgreSQL CDC with Lakeflow Connect

## Objective

Move from **file-level incremental ingestion** to **row-level change data capture (CDC)**.

Labs 01–04 taught:

```text
new file arrives
    ↓
ingest file incrementally
```

Lab 05 teaches:

```text
row INSERT / UPDATE / DELETE happens in PostgreSQL
    ↓
PostgreSQL WAL / logical replication
    ↓
Lakeflow Connect
    ↓
Databricks destination table stays synchronized
```

The key question is:

> What does a managed database ingestion layer do that a normal JDBC copy does not?

---

# Important prerequisite

The Lakeflow Connect PostgreSQL connector is currently **Public Preview**.

Before doing this lab, verify that the PostgreSQL connector is available in your Databricks workspace.

Databricks currently supports:

- UI-based pipeline authoring
- API-based pipeline authoring
- Declarative Automation Bundles
- incremental ingestion
- Unity Catalog governance
- SCD Type 2

PostgreSQL version **13 or later** is required.

---

# Architecture to understand first

A managed database connector has more moving parts than the Google Drive connector.

```text
PostgreSQL primary
     │
     │ WAL / logical replication
     ▼
Ingestion Gateway
     │
     │ snapshot + CDC files
     ▼
Staging Volume
     │
     ▼
Ingestion Pipeline
     │
     ▼
Streaming / Delta destination tables
```

## Component 1 — PostgreSQL source

The source owns:

- database availability
- WAL
- logical replication configuration
- publication
- replication slot
- replica identity
- source permissions

## Component 2 — Ingestion gateway

The gateway:

- connects to PostgreSQL
- performs the initial snapshot
- continuously reads PostgreSQL logical replication
- captures INSERT / UPDATE / DELETE changes
- writes extracted snapshot/CDC data to staging

Important:

```text
Gateway runtime = classic compute
Gateway mode    = continuous
```

It must run continuously so the replication slot does not retain WAL indefinitely.

## Component 3 — Staging volume

The staging volume is a Unity Catalog volume.

It temporarily holds:

- snapshot data
- CDC/change data
- metadata required between gateway and ingestion pipeline

This separation lets the gateway continuously capture source changes even if the destination ingestion pipeline runs on a schedule.

## Component 4 — Ingestion pipeline

The ingestion pipeline:

- reads the staged snapshot/change data
- applies it to destination tables
- runs on serverless compute
- can run on a schedule

This is a major concept:

```text
Gateway          = continuously capture source changes
Ingestion pipeline = apply those changes to Databricks tables
```

Do not treat them as the same process.

---

# Lab source model

Use a very small PostgreSQL table:

```sql
CREATE TABLE public.efuse_status (
    vehicle_id      VARCHAR(20) NOT NULL,
    fuse_id         VARCHAR(20) NOT NULL,
    current_a       NUMERIC(10,2),
    voltage_v       NUMERIC(10,2),
    switch_state    INTEGER,
    temperature_c   INTEGER,
    status          VARCHAR(30),
    updated_at      TIMESTAMP,
    PRIMARY KEY (vehicle_id, fuse_id)
);
```

Insert three starting rows:

```sql
INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V123', 'F17', 21.40, 12.10, 1, 62, 'OK', CURRENT_TIMESTAMP),
('V124', 'F03',  8.70, 12.40, 1, 49, 'OK', CURRENT_TIMESTAMP),
('V125', 'F07', 17.20, 12.30, 1, 55, 'OK', CURRENT_TIMESTAMP);
```

Expected source state:

```text
3 rows
```

---

# Step 1 — Prepare PostgreSQL for logical replication

This step happens **inside PostgreSQL**, not Databricks.

You need PostgreSQL admin / superuser / table-owner access for the source setup.

## 1.1 Verify PostgreSQL version

```sql
SELECT version();
```

Required:

```text
PostgreSQL 13+
```

---

## 1.2 Verify WAL level

Run:

```sql
SHOW wal_level;
```

Expected:

```text
logical
```

If it is not `logical`, change the PostgreSQL server configuration and restart the database as required by your PostgreSQL deployment.

Cloud-specific examples:

- Azure Database for PostgreSQL: enable logical replication in server parameters
- AWS RDS/Aurora: enable `rds.logical_replication`
- GCP Cloud SQL: enable logical decoding

---

## 1.3 Check replication capacity

Run:

```sql
SHOW max_replication_slots;
SHOW max_wal_senders;
```

There must be enough capacity for the Databricks replication slot and sender.

---

# Step 2 — Create a dedicated replication user

Do **not** use the PostgreSQL admin account inside the Databricks connection.

As PostgreSQL admin:

```sql
CREATE USER databricks_replication
WITH PASSWORD '<secure-password>';

ALTER USER databricks_replication
WITH REPLICATION;

GRANT CONNECT
ON DATABASE <database_name>
TO databricks_replication;

GRANT USAGE
ON SCHEMA public
TO databricks_replication;

GRANT SELECT
ON TABLE public.efuse_status
TO databricks_replication;
```

The two credential roles are intentionally different:

```text
PostgreSQL admin
    ↓
source setup only

databricks_replication user
    ↓
stored in Unity Catalog connection
    ↓
used by ingestion gateway
```

This is an important operational/security pattern.

---

# Step 3 — Configure replica identity

Because `efuse_status` has a primary key, normal/default replica identity is sufficient.

Verify:

```sql
SELECT
    relname,
    relreplident
FROM pg_class
WHERE relname = 'efuse_status';
```

For tables **without a primary key**, Databricks can replicate them if replica identity is set to:

```sql
ALTER TABLE public.some_table
REPLICA IDENTITY FULL;
```

Why this matters:

For UPDATE and DELETE events, PostgreSQL must provide enough old-row identity information for the connector to identify the affected destination row.

---

# Step 4 — Create the PostgreSQL publication

As the table owner/admin:

```sql
CREATE PUBLICATION databricks_publication
FOR TABLE public.efuse_status;
```

Verify:

```sql
SELECT *
FROM pg_publication;
```

and:

```sql
SELECT *
FROM pg_publication_tables
WHERE pubname = 'databricks_publication';
```

Expected table:

```text
public.efuse_status
```

The publication defines which source tables PostgreSQL exposes through logical replication.

---

# Step 5 — Create the logical replication slot

The replication slot should be created by the replication user.

If connected as admin:

```sql
SET ROLE databricks_replication;

SELECT pg_create_logical_replication_slot(
    'databricks_slot',
    'pgoutput'
);

RESET ROLE;
```

Verify:

```sql
SELECT
    slot_name,
    plugin,
    slot_type,
    active
FROM pg_replication_slots;
```

Expected:

```text
slot_name = databricks_slot
plugin    = pgoutput
```

## Critical operational point

Replication slots retain WAL until the consumer advances the slot.

Therefore:

> Do not create a replication slot and then abandon it indefinitely.

A stopped/unconsumed slot can cause WAL accumulation and eventually consume source disk space.

---

# Step 6 — Verify network connectivity

The Databricks **ingestion gateway** runs on classic compute and must be able to reach the PostgreSQL server.

Possible network paths include:

- public endpoint + firewall allow-listing
- VNet/VPC peering
- VPN
- Azure ExpressRoute
- AWS Direct Connect

For an Azure Database for PostgreSQL lab, make sure the database firewall/network configuration allows the Databricks gateway to connect.

You need:

```text
Host
Port
Database
Replication username
Replication password
```

Do not commit the password to GitHub.

---

# Step 7 — Create the Unity Catalog PostgreSQL connection

In Databricks:

```text
Catalog
  → External locations
  → Connections
  → Create connection
```

Choose:

```text
Connection type: PostgreSQL
```

Use:

```text
Connection name:
lab_postgres_cdc_connection
```

Authentication:

```text
Host:     <postgres-host>
User:     databricks_replication
Password: <replication-user-password>
```

Do **not** use the PostgreSQL admin credentials.

Save the connection.

---

# Step 8 — Create the managed PostgreSQL ingestion pipeline

Go to:

```text
Jobs & pipelines
  → Create new
  → Ingestion pipeline
```

Choose PostgreSQL as the source or select the existing connection:

```text
lab_postgres_cdc_connection
```

Pipeline name:

```text
lab-managed-postgres-cdc
```

The PostgreSQL connector supports UI-based pipeline authoring.

---

# Step 9 — Configure ingestion setup

You will now configure both the gateway and the ingestion pipeline.

Use a dedicated metadata/staging location where possible.

Recommended conceptual naming:

```text
Pipeline:       lab-managed-postgres-cdc
Gateway:        lab-postgres-cdc-gateway
Destination:    workspace.bronze
Target table:   efuse_status
```

Remember:

```text
Gateway     → classic compute, continuous
Pipeline    → serverless compute, scheduled/on demand
```

Do not configure the gateway as a periodic batch process.

---

# Step 10 — Select source table

Choose:

```text
Database: <your_database>
Schema:   public
Table:    efuse_status
```

For this lab, ingest only this one table.

Do not add multiple tables yet.

---

# Step 11 — Configure destination

Use the same learning catalog/schema pattern as earlier labs.

For example:

```text
Catalog: workspace
Schema:  bronze
```

Destination table:

```text
workspace.bronze.efuse_status
```

Then save/run the pipeline.

---

# Step 12 — Observe the initial snapshot

The first run does two things conceptually:

```text
Existing source rows
       ↓
initial snapshot
       ↓
destination

AND simultaneously

new source changes
       ↓
logical replication / WAL
       ↓
gateway
```

Because extraction and application are separate, the first ingestion-pipeline run can sometimes apply only part of the historical data if the gateway has not finished extracting the initial snapshot yet.

If that happens, run the ingestion pipeline again.

Validate:

```sql
SELECT *
FROM workspace.bronze.efuse_status
ORDER BY vehicle_id, fuse_id;
```

Expected final initial state:

```text
3 rows
```

---

# Experiment A — INSERT

In PostgreSQL:

```sql
INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V126', 'F12', 29.60, 11.90, 1, 68, 'OK', CURRENT_TIMESTAMP);
```

Now:

1. leave the gateway running continuously;
2. run the ingestion pipeline;
3. query Databricks.

```sql
SELECT *
FROM workspace.bronze.efuse_status
WHERE vehicle_id = 'V126';
```

Expected:

```text
row exists
```

Total expected count:

```text
4
```

---

# Experiment B — UPDATE

In PostgreSQL:

```sql
UPDATE public.efuse_status
SET
    current_a = 34.20,
    temperature_c = 76,
    status = 'HIGH_LOAD',
    updated_at = CURRENT_TIMESTAMP
WHERE vehicle_id = 'V123'
  AND fuse_id = 'F17';
```

Run the ingestion pipeline again.

Query Databricks:

```sql
SELECT
    vehicle_id,
    fuse_id,
    current_a,
    temperature_c,
    status
FROM workspace.bronze.efuse_status
WHERE vehicle_id = 'V123'
  AND fuse_id = 'F17';
```

Expected:

```text
current_a      = 34.20
temperature_c  = 76
status         = HIGH_LOAD
```

Critical observation:

> The destination should reflect the updated current row. We are no longer simply appending a new file.

---

# Experiment C — DELETE

In PostgreSQL:

```sql
DELETE FROM public.efuse_status
WHERE vehicle_id = 'V124'
  AND fuse_id = 'F03';
```

Run the ingestion pipeline.

Validate:

```sql
SELECT *
FROM workspace.bronze.efuse_status
WHERE vehicle_id = 'V124'
  AND fuse_id = 'F03';
```

Expected:

```text
0 rows
```

Total table count should return to:

```text
3
```

This is the key difference from file ingestion:

```text
File ingestion
   → detect new/changed files

Database CDC
   → detect row INSERT / UPDATE / DELETE
```

---

# Experiment D — Stop only the ingestion pipeline

This experiment teaches the gateway/pipeline separation.

## Step 1

Leave the **gateway running**.

Do not run the destination ingestion pipeline.

## Step 2

Perform source changes:

```sql
UPDATE public.efuse_status
SET
    status = 'THERMAL_WARNING',
    temperature_c = 91,
    updated_at = CURRENT_TIMESTAMP
WHERE vehicle_id = 'V125'
  AND fuse_id = 'F07';

INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V127', 'F03', 7.10, 12.50, 1, 50, 'OK', CURRENT_TIMESTAMP);
```

## Step 3

Wait a few minutes.

The gateway continues consuming PostgreSQL changes and staging them.

## Step 4

Run the ingestion pipeline.

Validate both changes appear.

### Learning

```text
Gateway:
keeps capturing source CDC

Ingestion pipeline:
can apply accumulated staged changes later
```

That is why the two components are separated.

---

# Experiment E — What NOT to do: stop the gateway for a long period

Do not use this as a normal operating model.

If the gateway is stopped while the PostgreSQL replication slot exists:

```text
PostgreSQL keeps producing WAL
          ↓
replication slot cannot advance
          ↓
WAL retained
          ↓
disk usage can grow
```

That is why Databricks requires the gateway to run continuously.

This is materially different from stopping a Google Drive ingestion pipeline.

---

# Experiment F — Observe source replication state

In PostgreSQL:

```sql
SELECT
    slot_name,
    active,
    restart_lsn,
    confirmed_flush_lsn
FROM pg_replication_slots
WHERE slot_name = 'databricks_slot';
```

Observe the slot while:

1. gateway is running;
2. source changes are generated;
3. ingestion pipeline is idle;
4. ingestion pipeline is run again.

The gateway, not the destination ingestion schedule, is what keeps consuming PostgreSQL WAL.

---

# Experiment G — Table without primary key

This is optional but very useful.

Create:

```sql
CREATE TABLE public.efuse_events_no_pk (
    vehicle_id VARCHAR(20),
    fuse_id VARCHAR(20),
    status VARCHAR(30)
);
```

Without a primary key, configure:

```sql
ALTER TABLE public.efuse_events_no_pk
REPLICA IDENTITY FULL;
```

Then grant privileges and add it to the publication:

```sql
GRANT SELECT
ON TABLE public.efuse_events_no_pk
TO databricks_replication;

ALTER PUBLICATION databricks_publication
ADD TABLE public.efuse_events_no_pk;
```

This demonstrates that CDC needs a reliable row identity for UPDATE/DELETE semantics.

---

# Monitoring checklist

## PostgreSQL

Inspect:

```sql
SELECT * FROM pg_replication_slots;
SELECT * FROM pg_stat_replication;
```

## Databricks gateway

Inspect:

- gateway job status
- classic compute status
- extraction progress
- errors
- source connectivity

## Databricks ingestion pipeline

Inspect:

- update history
- destination row changes
- serverless execution
- event log
- failed/retried updates

Keep these three monitoring layers conceptually separate.

---

# Cleanup

Database CDC has a cleanup responsibility that file ingestion did not.

When you permanently delete the ingestion pipeline/gateway, **do not forget the PostgreSQL replication slot**.

Databricks does not automatically remove the PostgreSQL replication slot when the ingestion pipeline is deleted.

After the lab is fully finished and no connector uses the slot:

```sql
SELECT pg_drop_replication_slot('databricks_slot');
```

Also remove the publication if you no longer need it:

```sql
DROP PUBLICATION databricks_publication;
```

Optionally remove the replication user:

```sql
DROP USER databricks_replication;
```

Only perform cleanup after confirming no pipeline depends on these objects.

---

# Managed CDC vs a simple JDBC copy

This is the architectural lesson of Lab 05.

## JDBC-style incremental query

You might build:

```sql
SELECT *
FROM efuse_status
WHERE updated_at > :last_watermark;
```

You then own:

- watermark storage
- update semantics
- delete detection
- retries
- replay
- failure recovery
- source polling
- destination MERGE logic

Deletes are particularly awkward because a deleted row no longer exists to satisfy your query.

## Managed PostgreSQL CDC

```text
PostgreSQL WAL
     ↓
logical replication
     ↓
gateway
     ↓
staging
     ↓
ingestion pipeline
     ↓
destination table
```

The connector can capture:

```text
INSERT
UPDATE
DELETE
```

without us implementing timestamp polling or row-level change detection.

---

# Final comparison with earlier labs

| Concept | Google Drive labs | PostgreSQL CDC |
|---|---|---|
| Incremental unit | File | Row change |
| Source change mechanism | File discovery/metadata | WAL logical replication |
| INSERT | New record in a file | Captured directly |
| UPDATE | Changed file / overwrite semantics | Captured directly |
| DELETE | Not natural row-level CDC | Captured directly |
| Persistent source cursor | File discovery state | Replication slot / WAL position |
| Always-on source capture | No | Yes, gateway |
| Staging layer | Hidden/connector-specific | Explicit UC staging volume |
| Source setup complexity | Low | High |
| Source operational risk | Low | WAL growth if slot is unmanaged |

---

# What Lab 05 should teach you

The progression is now:

```text
Lab 01
Managed file ingestion

Lab 02
Standard file ingestion

Lab 03
Incremental file state

Lab 04
Schema evolution

Lab 05
Row-level CDC
```

The crucial new mental model is:

```text
CDC is not:
"query the table every few minutes"

CDC is:
"consume the source database's change stream"
```

And for PostgreSQL, that source change stream is based on:

```text
WAL
+ logical replication
+ publication
+ replication slot
```

Lakeflow Connect then manages the gateway/staging/application machinery around that source-native CDC mechanism.
