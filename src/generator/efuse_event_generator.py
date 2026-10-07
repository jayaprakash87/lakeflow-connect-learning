"""Simple synthetic eFuse event generator.

This first version prints newline-delimited JSON.
A Kafka producer will be added when we configure the lab environment.
"""

import json
import random
import time
from datetime import datetime, timezone


FUSE_IDS = ["F03", "F07", "F12", "F17"]
VEHICLE_IDS = ["V123", "V124", "V125"]


def build_event() -> dict:
    return {
        "vehicle_id": random.choice(VEHICLE_IDS),
        "fuse_id": random.choice(FUSE_IDS),
        "current_a": round(random.uniform(5.0, 35.0), 1),
        "voltage_v": round(random.uniform(11.8, 12.8), 1),
        "switch_state": random.choice([0, 1]),
        "event_ts": datetime.now(timezone.utc).isoformat(),
    }


if __name__ == "__main__":
    while True:
        print(json.dumps(build_event()), flush=True)
        time.sleep(1)
