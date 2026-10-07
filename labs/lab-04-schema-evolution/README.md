# Lab 04 — Schema evolution

## Baseline

Start with JSON files containing:

```json
{
  "vehicle_id": "V123",
  "fuse_id": "F17",
  "current_a": 21.4,
  "voltage_v": 12.1,
  "switch_state": 1,
  "event_ts": "2026-10-07T14:00:00Z"
}
```

## Change

Add a new file whose records also contain:

```json
"temperature_c": 62
```

## Compare

For managed and standard ingestion, record:

- Does ingestion continue?
- Does the destination schema change?
- Which schema-evolution option controls the behavior?
- Can new columns be rescued instead of added?
- Can the pipeline be configured to fail on new columns?
- Is a restart or full refresh required?

## Learning target

Both approaches can support schema evolution. The key question is **where the behavior is configured and who owns the ingestion logic**.
