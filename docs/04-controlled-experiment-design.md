# Controlled experiment design

To learn managed ingestion correctly, change one variable at a time.

## Constant across Lab 01 and Lab 02

~~~text
Source cluster
Topic
Messages
Starting position
Logical target
Bronze data contract
~~~

## Variable

~~~text
Ingestion abstraction
~~~

Lab 01 uses the managed Lakeflow Connect Kafka connector.

Lab 02 uses the standard Spark/Lakeflow Kafka source.

## Bronze contract

Both paths retain the raw Kafka key, raw Kafka value, and Kafka position metadata.

JSON parsing is deliberately downstream for the first experiment.

## Why this matters

If the managed path parses JSON while the standard path keeps binary messages, differences in code, schema handling, and failure behavior are partly caused by transformation choices.

A controlled experiment lets us attribute differences to the management boundary itself.

## Later experiment

After the ingestion comparison is understood, we will deliberately enable the managed connector's JSON value transformer and schema-evolution behavior, then compare that with explicit parsing and schema handling in the standard path.
