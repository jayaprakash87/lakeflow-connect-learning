"""Lab 07 — Standard Kafka -> Lakeflow streaming table.

This deliberately preserves the same Bronze contract as Lab 06:
- key: BINARY
- value: BINARY
- _kafka_metadata: STRUCT

Business JSON parsing is deferred so we compare ingestion abstractions fairly.

Authentication:
- Preferred for supported cloud-managed Kafka: Unity Catalog service credential.
- For generic SASL Kafka, store credentials in a Databricks secret scope.
"""

from pyspark import pipelines as dp
from pyspark.sql import functions as F


BOOTSTRAP_SERVERS = spark.conf.get("kafka.bootstrap_servers")
TOPIC = spark.conf.get("kafka.topic", "efuse-events")
AUTH_MODE = spark.conf.get("kafka.auth_mode", "service_credential")


def kafka_stream():
    reader = (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", BOOTSTRAP_SERVERS)
        .option("subscribe", TOPIC)
        .option("startingOffsets", "earliest")
        .option("includeHeaders", "true")
    )

    if AUTH_MODE == "service_credential":
        service_credential = spark.conf.get("kafka.service_credential")
        reader = reader.option(
            "databricks.serviceCredential",
            service_credential,
        )

    elif AUTH_MODE == "sasl_plain":
        username = dbutils.secrets.get(scope="kafka-lab", key="username")
        password = dbutils.secrets.get(scope="kafka-lab", key="password")

        jaas = (
            "org.apache.kafka.common.security.plain.PlainLoginModule required "
            f'username="{username}" password="{password}";'
        )

        reader = (
            reader
            .option("kafka.security.protocol", "SASL_SSL")
            .option("kafka.sasl.mechanism", "PLAIN")
            .option("kafka.sasl.jaas.config", jaas)
        )

    else:
        raise ValueError(
            "Unsupported kafka.auth_mode. "
            "Use 'service_credential' or 'sasl_plain'."
        )

    return reader.load()


@dp.table(
    name="efuse_events_standard",
    comment="Raw Kafka Bronze table for Lab 07 standard ingestion comparison",
)
def efuse_events_standard():
    raw = kafka_stream()

    return raw.select(
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
