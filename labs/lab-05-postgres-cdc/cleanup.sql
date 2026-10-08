-- Lab 05 — PostgreSQL cleanup
-- Run only after the Databricks CDC pipeline/gateway is permanently removed
-- and no connector depends on these source objects.

-- Check slot first
SELECT
    slot_name,
    active
FROM pg_replication_slots
WHERE slot_name = 'databricks_slot';

-- Drop the logical replication slot.
SELECT pg_drop_replication_slot('databricks_slot');

-- Drop publication.
DROP PUBLICATION databricks_publication;

-- Optional lab table cleanup.
-- DROP TABLE public.efuse_status;

-- Optional replication user cleanup.
-- Ensure privileges/dependencies are removed first.
-- DROP USER databricks_replication;
