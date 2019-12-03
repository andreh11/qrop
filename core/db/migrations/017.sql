-- 017
-- add crop_stat_view

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE VIEW IF NOT EXISTS crop_stat_view AS
SELECT crop_id,
       crop,
       strftime('%Y', planting_date) AS year,
       COUNT(distinct variety_id) AS variety_number,
       SUM(length) AS total_length,
       SUM(length * yield_per_bed_meter) AS total_yield,
       SUM(bed_revenue) AS total_revenue,
       SUM(CASE WHEN in_greenhouse = 0 THEN length ELSE 0 END) AS field_length,
       SUM(CASE WHEN in_greenhouse = 0 THEN length * yield_per_bed_meter ELSE 0 END) AS field_yield,
       SUM(CASE WHEN in_greenhouse = 0 THEN bed_revenue ELSE 0 END) AS field_revenue,
       SUM(CASE WHEN in_greenhouse = 1 THEN length ELSE 0 END) AS greenhouse_length,
       SUM(CASE WHEN in_greenhouse = 1 THEN length * yield_per_bed_meter ELSE 0 END) AS greenhouse_yield,
       SUM(CASE WHEN in_greenhouse = 1 THEN bed_revenue ELSE 0 END) AS greenhouse_revenue
FROM planting_view
GROUP BY year, crop_id;

PRAGMA user_version = 17;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
