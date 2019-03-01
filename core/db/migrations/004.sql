
-- * add a seed list view

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE VIEW seed_list_view AS
SELECT strftime("%Y", sowing_date) as year,
       crop_id, crop, variety, seed_company,
       sum(seeds_number) as seeds_number,
       sum(seeds_number*1.0/seeds_per_gram) as seeds_quantity
FROM planting_view
WHERE planting_type = 1 OR planting_type = 2
GROUP BY year, variety_id
ORDER BY crop, variety, seed_company ASC;

CREATE VIEW transplant_list_view AS
SELECT strftime("%Y", planting_date) as year,
       planting_date, crop_id, crop, variety, seed_company,
       sum(plants_needed) as plants_needed
FROM planting_view
WHERE planting_type = 3
GROUP BY planting_date, crop
ORDER BY planting_date, crop, variety, seed_company ASC;

-- GROUP BY year, variety_id
-- ORDER BY crop, variety, seed_company ASC;

PRAGMA user_version = 4;

COMMIT;

PRAGMA foreign_keys = ON;
