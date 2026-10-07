# Lab 01 — Managed Kafka ingestion

## Objective

Ingest `efuse-events` into Databricks using the **Lakeflow Connect managed Kafka connector** without writing Spark ingestion code.

## Target

`bronze.efuse_events_managed`

## What to record

- connection object created
- authentication method
- topic selection
- destination configuration
- continuous vs scheduled behavior
- objects Databricks creates
- monitoring information available
- where offset/state information is exposed, if at all
- restart behavior

## Success criterion

New Kafka events appear in the destination table and can be queried from Databricks.

## Observation log

| Question | Observation |
|---|---|
| How much code did we write? | |
| What did we configure? | |
| Who owns offsets/state? | |
| Who owns retries? | |
| Who owns runtime? | |
| How is monitoring exposed? | |
| What happens after restart? | |
