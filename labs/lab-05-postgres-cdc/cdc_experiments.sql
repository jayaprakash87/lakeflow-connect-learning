-- Lab 05 — CDC experiments
-- Run these in PostgreSQL one experiment at a time.

-- A. INSERT
INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V126', 'F12', 29.60, 11.90, 1, 68, 'OK', CURRENT_TIMESTAMP);

-- B. UPDATE
UPDATE public.efuse_status
SET
    current_a = 34.20,
    temperature_c = 76,
    status = 'HIGH_LOAD',
    updated_at = CURRENT_TIMESTAMP
WHERE vehicle_id = 'V123'
  AND fuse_id = 'F17';

-- C. DELETE
DELETE FROM public.efuse_status
WHERE vehicle_id = 'V124'
  AND fuse_id = 'F03';

-- D. Changes while destination ingestion pipeline is idle
UPDATE public.efuse_status
SET
    status = 'THERMAL_WARNING',
    temperature_c = 91,
    updated_at = CURRENT_TIMESTAMP
WHERE vehicle_id = 'V125'
  AND fuse_id = 'F07';

INSERT INTO public.efuse_status
(vehicle_id, fuse_id, current_a, voltage_v, switch_state, temperature_c, status, updated_at)
VALUES
('V127', 'F03', 7.10, 12.50, 1, 50, 'OK', CURRENT_TIMESTAMP);

-- Inspect final source state
SELECT *
FROM public.efuse_status
ORDER BY vehicle_id, fuse_id;
