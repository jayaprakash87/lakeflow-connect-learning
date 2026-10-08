# Lab 07 — Restart/state experiment

## Objective

Prove that standard Kafka ingestion inside Lakeflow is also stateful.

## Step 1

Run `lab-standard-kafka-efuse`.

Record the current maximum Kafka offset:

```sql
SELECT
  _kafka_metadata.partition,
  MAX(_kafka_metadata.offset) AS max_offset
FROM main.bronze.efuse_events_standard
GROUP BY _kafka_metadata.partition;
```

## Step 2

Do not Full Refresh.

Stop after the triggered update completes, or stop continuous execution normally.

## Step 3

Produce approximately five new messages.

## Step 4

Run/start the pipeline again.

## Step 5

Re-run the offset query.

Expected:

- maximum offset increases;
- old records are not duplicated;
- `startingOffsets = earliest` is not reapplied because streaming progress already exists.

## Learning

```text
Standard Kafka source code is explicit.

Streaming progress/checkpoint lifecycle inside the Lakeflow streaming table
is still managed by Lakeflow.
```

This is why "standard" does not mean "everything is manual."
