# Lab 02 — Standard/custom Kafka ingestion

## Objective

Ingest the same `efuse-events` topic using Spark Structured Streaming in a Lakeflow pipeline.

## Target

`bronze.efuse_events_standard`

## Principle

The source event and desired output are intentionally the same as Lab 01. Only the ingestion abstraction changes.

## Starting point

See `src/standard_ingestion/kafka_to_bronze.py`.

## Observation log

| Question | Observation |
|---|---|
| How much code did we write? | |
| Which Kafka options did we configure? | |
| How is state/checkpointing handled? | |
| Who owns retries/recovery? | |
| Who owns schema parsing? | |
| Who owns runtime? | |
| How is monitoring exposed? | |
