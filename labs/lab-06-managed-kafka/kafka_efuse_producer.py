"""Produce synthetic eFuse JSON events to Kafka.

Required environment variables:
  KAFKA_BOOTSTRAP_SERVERS
  KAFKA_API_KEY
  KAFKA_API_SECRET

Optional:
  KAFKA_TOPIC (default: efuse-events)

Do not commit real credentials.
"""

import json
import os
import random
import time
from datetime import datetime, timezone

from confluent_kafka import Producer


TOPIC = os.getenv("KAFKA_TOPIC", "efuse-events")
BOOTSTRAP_SERVERS = os.environ["KAFKA_BOOTSTRAP_SERVERS"]
API_KEY = os.environ["KAFKA_API_KEY"]
API_SECRET = os.environ["KAFKA_API_SECRET"]

VEHICLE_IDS = ["V123", "V124", "V125"]
FUSE_IDS = ["F03", "F07", "F12", "F17"]


def build_event() -> dict:
    return {
        "vehicle_id": random.choice(VEHICLE_IDS),
        "fuse_id": random.choice(FUSE_IDS),
        "current_a": round(random.uniform(5.0, 35.0), 1),
        "voltage_v": round(random.uniform(11.8, 12.8), 1),
        "switch_state": random.choice([0, 1]),
        "event_ts": datetime.now(timezone.utc).isoformat(),
    }


def delivery_report(err, msg):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(
            f"Delivered to {msg.topic()} "
            f"partition={msg.partition()} offset={msg.offset()}"
        )


producer = Producer(
    {
        "bootstrap.servers": BOOTSTRAP_SERVERS,
        "security.protocol": "SASL_SSL",
        "sasl.mechanisms": "PLAIN",
        "sasl.username": API_KEY,
        "sasl.password": API_SECRET,
    }
)


if __name__ == "__main__":
    print(f"Producing to topic: {TOPIC}")

    try:
        while True:
            event = build_event()
            producer.produce(
                TOPIC,
                key=event["vehicle_id"],
                value=json.dumps(event),
                callback=delivery_report,
            )
            producer.poll(0)
            print(json.dumps(event))
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        producer.flush()
