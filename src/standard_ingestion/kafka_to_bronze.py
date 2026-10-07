"""Lab 02 skeleton: Kafka -> Databricks using Structured Streaming.

Values are placeholders until the Kafka environment and Databricks connection
details are available.
"""

from pyspark.sql import functions as F
from pyspark.sql.types import (
    DoubleType,
    IntegerType,
    StringType,
    StructField,
    StructType,
)


event_schema = StructType(
    [
        StructField("vehicle_id", StringType(), False),
        StructField("fuse_id", StringType(), False),
        StructField("current_a", DoubleType(), True),
        StructField("voltage_v", DoubleType(), True),
        StructField("switch_state", IntegerType(), True),
        StructField("event_ts", StringType(), False),
    ]
)


raw = (
    spark.readStream
    .format("kafka")
    .option("kafka.bootstrap.servers", "<bootstrap-servers>")
    .option("subscribe", "efuse-events")
    .option("startingOffsets", "latest")
    .load()
)

parsed = (
    raw.select(
        F.from_json(F.col("value").cast("string"), event_schema).alias("event"),
        F.col("topic"),
        F.col("partition"),
        F.col("offset"),
        F.col("timestamp").alias("kafka_timestamp"),
    )
    .select("event.*", "topic", "partition", "offset", "kafka_timestamp")
)

# The exact Lakeflow pipeline declaration/writer will be added when the
# workspace/runtime style for the lab is selected.
