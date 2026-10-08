-- Lab 05 — Databricks validation
-- Replace workspace.bronze if your target differs.

SELECT *
FROM workspace.bronze.efuse_status
ORDER BY vehicle_id, fuse_id;

SELECT COUNT(*) AS row_count
FROM workspace.bronze.efuse_status;

-- Validate UPDATE
SELECT
    vehicle_id,
    fuse_id,
    current_a,
    temperature_c,
    status
FROM workspace.bronze.efuse_status
WHERE vehicle_id = 'V123'
  AND fuse_id = 'F17';

-- Validate DELETE
SELECT *
FROM workspace.bronze.efuse_status
WHERE vehicle_id = 'V124'
  AND fuse_id = 'F03';

-- Validate changes accumulated while the destination pipeline was idle
SELECT
    vehicle_id,
    fuse_id,
    temperature_c,
    status
FROM workspace.bronze.efuse_status
WHERE vehicle_id IN ('V125', 'V127')
ORDER BY vehicle_id;
