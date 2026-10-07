# Lab 04 — Schema evolution

## Baseline event

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

Add:

```json
"temperature_c": 62
```

## Compare

- Does ingestion continue?
- Does the target schema change automatically?
- Is the field ignored, rescued, or rejected?
- Is configuration required?
- Is a restart required?
- What is visible in monitoring?

Do not assume the two paths should behave identically. The purpose is to observe their defined schema semantics.
