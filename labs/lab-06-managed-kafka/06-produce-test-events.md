# Lab 06 — Produce test events

The included producer creates synthetic eFuse events.

## Step 1 — Install dependency

From:

```text
labs/lab-06-managed-kafka
```

run:

```bash
python -m pip install -r requirements.txt
```

---

# Step 2 — Configure environment variables

Copy:

```bash
cp .env.example .env
```

The sample producer expects:

```text
KAFKA_BOOTSTRAP_SERVERS
KAFKA_API_KEY
KAFKA_API_SECRET
KAFKA_TOPIC=efuse-events
```

Do not commit the populated `.env`.

The repository's `.gitignore` excludes `.env` files.

---

# Step 3 — Export variables

## PowerShell

```powershell
$env:KAFKA_BOOTSTRAP_SERVERS="<host:port>"
$env:KAFKA_API_KEY="<username-or-api-key>"
$env:KAFKA_API_SECRET="<password-or-api-secret>"
$env:KAFKA_TOPIC="efuse-events"
```

## Bash

```bash
export KAFKA_BOOTSTRAP_SERVERS="<host:port>"
export KAFKA_API_KEY="<username-or-api-key>"
export KAFKA_API_SECRET="<password-or-api-secret>"
export KAFKA_TOPIC="efuse-events"
```

---

# Step 4 — Produce the initial batch BEFORE starting the pipeline

Run:

```bash
python kafka_efuse_producer.py
```

Let it produce approximately:

```text
10 records
```

Then stop with Ctrl+C.

Expected delivery output:

```text
Delivered to efuse-events partition=0 offset=0
Delivered to efuse-events partition=0 offset=1
...
```

Write down the highest produced offset.

Example:

```text
highest offset before pipeline start = 9
```

---

# Why produce first?

Our managed pipeline uses:

```text
starting_offset = earliest
```

Therefore, on its first run with no checkpoint, it should ingest messages already present in the topic.

If we used the default:

```text
latest
```

those pre-existing records would be skipped and only new messages arriving after startup would be consumed.

This experiment makes `starting_offset` visible rather than theoretical.

---

# Step 5 — Produce live records after the pipeline starts

Once the managed pipeline is running continuously, start the producer again.

Produce another:

```text
5–10 events
```

The destination table should grow while the pipeline remains running.

This demonstrates:

```text
continuous streaming consumption
```

rather than scheduled polling.
