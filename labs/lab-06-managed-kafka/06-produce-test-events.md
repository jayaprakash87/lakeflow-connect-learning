# Lab 06 — Produce test events

The included producer is a simple SASL/PLAIN example. Adapt authentication options if your Kafka provider uses a different mechanism.

## 1. Install dependency

From this directory:

```bash
python -m pip install -r requirements.txt
```

## 2. Set credentials locally

Copy:

```bash
cp .env.example .env
```

Do not commit the completed `.env`.

Required by the sample producer:

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
python kafka_efuse_producer.py
```

Let it create roughly 10–20 events, then stop with Ctrl+C.

## Why produce before starting ingestion?

The managed pipeline uses:

```text
starting_offset = earliest
```

on the first run when no checkpoint exists. This lets us verify that existing topic data is ingested.

Once checkpointed state exists, restart behavior should be driven by that state rather than reapplying the initial starting-offset instruction.
