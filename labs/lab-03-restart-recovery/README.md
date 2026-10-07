# Lab 03 — Restart and recovery

## Experiment

1. Produce a known sequence of events.
2. Confirm both targets are current.
3. Stop ingestion.
4. Produce additional events.
5. Restart ingestion.
6. Compare whether either path loses or duplicates data.

## Record

- last processed event before stop
- first event after restart
- duplicates
- missing events
- recovery time
- configuration required for recovery
- where state is persisted

The learning goal is to understand what "managed state and recovery" means in practice.
