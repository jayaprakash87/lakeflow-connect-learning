-- Lab 05 — PostgreSQL source setup
-- Run the appropriate sections using a PostgreSQL admin/table owner.
-- Replace placeholders before execution.

-- 1. Environment checks
SELECT version();
SHOW wal_level;
SHOW max_replication_slots;
SHOW max_wal_senders;

-- 2. Lab source table
CREATE TABLE IF NOT EXISTS public.efuse_status (
    vehicle_id      VARCHAR(20) NOT NULL,
    fuse_id         VARCHAR(20) NOT NULL,
    current_a       NUMERIC(10,2),
    voltage_v       NUMERIC(10,2),
    switch_state    INTEGER,
    temperature_c   INTEGER,
    status          VARCHAR(30),
    updated_at      TIMESTAMP,
    PRIMARY KEY (vehicle_id, fuse_id)
);

INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V123', 'F17', 21.40, 12.10, 1, 62, 'OK', CURRENT_TIMESTAMP),
('V124', 'F03',  8.70, 12.40, 1, 49, 'OK', CURRENT_TIMESTAMP),
('V125', 'F07', 17.20, 12.30, 1, 55, 'OK', CURRENT_TIMESTAMP)
ON CONFLICT (vehicle_id, fuse_id) DO NOTHING;

-- 3. Replication user
CREATE USER databricks_replication WITH PASSWORD '<REPLACE_ME>';
ALTER USER databricks_replication WITH REPLICATION;

GRANT CONNECT
ON DATABASE <database_name>
TO databricks_replication;

GRANT USAGE
ON SCHEMA public
TO databricks_replication;

GRANT SELECT
ON TABLE public.efuse_status
TO databricks_replication;

-- 4. Publication
CREATE PUBLICATION databricks_publication
FOR TABLE public.efuse_status;

-- 5. Replication slot
-- The slot should be created by the replication user.
SET ROLE databricks_replication;

SELECT pg_create_logical_replication_slot(
    'databricks_slot',
    'pgoutput'
);

RESET ROLE;

-- 6. Verify
SELECT * FROM pg_publication;

SELECT *
FROM pg_publication_tables
WHERE pubname = 'databricks_publication';

SELECT
    slot_name,
    plugin,
    slot_type,
    active
FROM pg_replication_slots
WHERE slot_name = 'databricks_slot';
