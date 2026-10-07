# Lab 05 — PostgreSQL CDC

## Objective

Repeat the managed-ingestion concept using database CDC, where the value of a managed connector becomes especially visible.

```text
PostgreSQL
   ↓
CDC / transaction log
   ↓
Lakeflow Connect
   ↓
bronze.postgres_*
```

## Experiments

- initial snapshot
- INSERT
- UPDATE
- DELETE
- stop/restart
- schema change

## Questions

- How is initial load separated from incremental capture?
- What source-side prerequisites are required?
- What CDC position/state is maintained?
- How are deletes represented/applied?
- What happens after an outage?
- Which components are continuously running?
