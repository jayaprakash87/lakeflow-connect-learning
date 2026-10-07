# Lab 01 — Produce test events

## 1. Install dependency

```bash
python -m pip install -r requirements.txt
```

## 2. Set credentials locally

Copy the template:

```bash
cp .env.example .env
```

Do not commit the completed `.env` file.

The producer reads environment variables, so either export them in your shell or load them using your preferred local environment tooling.

Required variables:

```text
KAFKA_BOOTSTRAP_SERVERS
KAFKA_API_KEY
KAFKA_API_SECRET
```

Optional:

```text
KAFKA_TOPIC=efuse-events
```

## 3. Run the producer

```bash
python src/generator/kafka_efuse_producer.py
```

Expected output resembles:

```text
Delivered to efuse-events partition=0 offset=0
{"vehicle_id": "V123", ...}
Delivered to efuse-events partition=0 offset=1
{"vehicle_id": "V124", ...}
```

Let it create roughly 10–20 events, then stop it with Ctrl+C.

## Why produce data before starting ingestion?

Our first managed connector run will use:

```text
starting_offset = earliest
```

This gives us an easy experiment:

```text
messages already exist in Kafka
        ↓
start managed connector
        ↓
does it ingest historical messages?
```

Later we will switch our thinking to checkpoint behavior: once a checkpoint exists, restart should resume from managed state rather than reapply the initial starting-offset instruction.
