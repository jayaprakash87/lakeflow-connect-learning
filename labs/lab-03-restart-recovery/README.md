# Lab 03 — Incremental state and restart

## Objective

Use the Google Drive managed and standard pipelines from Labs 01 and 02 to understand **incremental state**.

## Experiment

1. Place file `batch-001.json` in the shared source folder.
2. Run both ingestion paths.
3. Confirm both destinations contain the first batch.
4. Stop/pause both pipelines.
5. Add `batch-002.json`.
6. Restart both pipelines.
7. Compare what gets processed.

## Questions

- Does either path reread `batch-001.json`?
- Where is progress/state managed?
- Do we configure a checkpoint path ourselves?
- What evidence is visible in pipeline monitoring?
- What happens if a previously ingested file is modified?
- What happens if a new file appears while the pipeline is stopped?

## Learning target

The important distinction is not merely whether both pipelines recover.

It is **how much of the state-management mechanism is exposed to us**.
