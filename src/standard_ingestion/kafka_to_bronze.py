"""Lab 02: Kafka -> Databricks using Structured Streaming.

This intentionally preserves the same Bronze contract as Lab 01:
- key: BINARY
- value: BINARY
- Kafka source metadata

Business JSON parsing is deliberately deferred so the experiment compares
ingestion ownership rather than transformation logic.
"""

from pyspark.sql import functions as F


raw = (
    spark.readStream
    .format("kafka")
    .option("kafka.bootstrap.servers", "<bootstrap-servers>")
    .option("subscribe", "efuse-events")
    .option("startingOffsets", "earliest")
    .load()
)

bronze = raw.select(
    F.col("key"),
    F.col("value"),
    F.struct(
        F.col("topic").alias("topic"),
        F.col("partition").alias("partition"),
        F.col("offset").alias("offset"),
        F.col("timestamp").alias("timestamp"),
        F.col("timestampType").alias("timestampType"),
        F.col("headers").alias("headers"),
    ).alias("_kafka_metadata"),
)

# In a Lakeflow pipeline, expose the bronze DataFrame as the streaming table.
# Authentication is deliberately not hard-coded; Lab 02 will configure it
# securely and compare that responsibility with Lab 01's UC Connection.
