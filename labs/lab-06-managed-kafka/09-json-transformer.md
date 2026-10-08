# Lab 06 — JSON transformer experiment

## Why this comes after raw ingestion

The first Kafka experiment deliberately writes:

```text
key   BINARY
value BINARY
```

That isolates ingestion mechanics.

Now we can ask:

> Can the managed connector also deserialize the Kafka payload?

Yes.

The managed Kafka connector supports value/key transformers including JSON.

---

# Raw mode

Without a transformer:

```text
value = BINARY
```

We can inspect it with:

```sql
CAST(value AS STRING)
```

---

# JSON transformer

When the value transformer uses:

```text
format: JSON
```

the connector can deserialize JSON.

If no explicit JSON schema is supplied, the parsed value can be written as a `VARIANT`.

If a schema/schema file is provided, the connector can create typed fields.

Schema evolution options can also be configured for JSON deserialization.

---

# Why this matters architecturally

There are now two legitimate designs:

## Design A — Raw Bronze

```text
Kafka
  ↓
managed connector
  ↓
raw key/value + metadata
  ↓
Bronze
  ↓
downstream parse/validate
```

Benefits:

- preserves source payload;
- maximizes replay/debug capability;
- separates ingestion from business transformation.

## Design B — Parse during ingestion

```text
Kafka JSON
   ↓
managed JSON transformer
   ↓
parsed destination
```

Benefits:

- less downstream parsing code;
- simpler destination for well-governed schemas.

Trade-off:

- ingestion becomes more coupled to source schema.

---

# Learning conclusion

Managed Kafka is not limited to raw byte copying.

But for our controlled managed-vs-standard comparison, keep Lab 06's primary table raw so that Lab 07 can reproduce the same Bronze contract using Structured Streaming.
