-- 015
-- add month and quarter seed lists views

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE VIEW IF NOT EXISTS seed_list_month_view AS
SELECT strftime("%Y", sowing_date) as year,
       CAST(strftime("%m", sowing_date) AS INTEGER) AS month,
       crop_id, crop, variety, seed_company,
       sum(seeds_number) as seeds_number,
       sum(seeds_quantity) as seeds_quantity
FROM planting_view
WHERE planting_type = 1 OR planting_type = 2
GROUP BY year, month, variety_id
ORDER BY year, month, crop, variety, seed_company ASC;

CREATE VIEW IF NOT EXISTS seed_list_quarter_view AS
SELECT strftime("%Y", sowing_date) as year,
       CASE WHEN CAST(strftime("%m", sowing_date) AS INTEGER) < 4 THEN 1
            WHEN CAST(strftime("%m", sowing_date) AS INTEGER) < 7 THEN 2
            WHEN CAST(strftime("%m", sowing_date) AS INTEGER) < 10 THEN 3
            ELSE 4
       END trimester,
       crop_id, crop, variety, seed_company,
       sum(seeds_number) as seeds_number,
       sum(seeds_quantity) as seeds_quantity
FROM planting_view
WHERE planting_type = 1 OR planting_type = 2
GROUP BY year, trimester, variety_id
ORDER BY year, trimester, crop, variety, seed_company ASC;

PRAGMA user_version = 15;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
