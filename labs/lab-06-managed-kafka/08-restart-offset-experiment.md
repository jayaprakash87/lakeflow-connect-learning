# Lab 06 — Restart and offset experiment

## Objective

Prove that `starting_offset: earliest` is a **first-state initialization rule**, not a command to reread the entire Kafka topic every time the pipeline starts.

---

# Starting state

Assume the pipeline has already consumed offsets:

```text
0 ... 14
```

Verify:

```sql
SELECT
  _kafka_metadata.partition,
  MIN(_kafka_metadata.offset) AS min_offset,
  MAX(_kafka_metadata.offset) AS max_offset,
  COUNT(*) AS records
FROM bronze.efuse_events_managed
GROUP BY _kafka_metadata.partition;
```

Write down the maximum offset.

---

# Step 1 — Stop the pipeline normally

Open:

```text
Jobs & pipelines
  → lakeflow-managed-kafka-efuse
```

Stop the continuous pipeline.

Do not reset or full refresh it.

---

# Step 2 — Produce events while ingestion is stopped

Run:

```bash
python kafka_efuse_producer.py
```

Produce approximately five events.

Example new offsets:

```text
15
16
17
18
19
```

Stop the producer.

---

# Step 3 — Confirm Databricks has not consumed them yet

The destination maximum offset should still be the old value.

---

# Step 4 — Restart the managed pipeline

Start:

```text
lakeflow-managed-kafka-efuse
```

Wait until the new messages are consumed.

---

# Step 5 — Validate

Run:

```sql
SELECT
  _kafka_metadata.partition,
  MIN(_kafka_metadata.offset) AS min_offset,
  MAX(_kafka_metadata.offset) AS max_offset,
  COUNT(*) AS records
FROM bronze.efuse_events_managed
GROUP BY _kafka_metadata.partition;
```

Expected:

- old records are not duplicated;
- new offsets appear;
- consumption resumes after the previous checkpoint.

---

# Why `earliest` did not reread from offset 0

The connector rule is:

```text
If checkpoint exists
    → resume from checkpoint

If no checkpoint exists
    → use starting_offset
```

So:

```text
starting_offset = earliest
```

does **not** mean:

```text
always start from earliest
```

It means:

```text
on first initialization, when no progress state exists,
start from the earliest retained Kafka record
```

This is one of the most important Kafka ingestion concepts in the lab.

---

# Full refresh warning

A reset/full-refresh-style operation changes the experiment because progress state may be rebuilt.

Never use Full Refresh when testing normal restart behavior.
