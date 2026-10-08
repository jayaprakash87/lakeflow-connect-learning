# Lab 07 — Standard/custom Kafka ingestion

## Objective

Ingest the same efuse-events topic with the standard Kafka source in Spark Structured Streaming / Lakeflow pipelines.

## Target

bronze.efuse_events_standard

## Critical experimental rule

Lab 01 and Lab 07 must have the same Bronze contract:

~~~text
key               BINARY
value             BINARY
_kafka_metadata   STRUCT
~~~

We deliberately do not parse the eFuse JSON during ingestion.

If one path performs business parsing and the other does not, we would be comparing ingestion and transformation at the same time. That would make the experiment invalid.

## Architecture

~~~text
Kafka topic: efuse-events
        ↓
Spark Structured Streaming Kafka source
        ↓
Lakeflow pipeline
        ↓
bronze.efuse_events_standard
~~~

## Starting point

See src/standard_ingestion/kafka_to_bronze.py.

## Observation log

| Question | Observation |
|---|---|
| How much code did we write? | |
| Which Kafka options did we configure? | |
| Where did authentication configuration live? | |
| How is starting offset configured? | |
| How is ongoing state/checkpointing handled? | |
| Who owns recovery behavior? | |
| Who creates the destination table? | |
| Who owns runtime configuration? | |
| How is monitoring exposed? | |

## Why this lab matters

Both paths ultimately use streaming machinery. The question is not whether streaming exists underneath.

The question is:

> Which pieces are exposed to us as application/pipeline engineering concerns, and which pieces are hidden behind the managed connector abstraction?
