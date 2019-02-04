-- 003
-- * add a harvest view

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE VIEW harvest_view AS
SELECT harvest_id as harvest_view_id,
       harvest.*,
       crop_id, crop, variety, unit.abbreviation as unit,
       group_concat(planting_location.location_id) as locations
FROM harvest
LEFT JOIN planting USING (planting_id)
LEFT JOIN planting_location USING (planting_id)
LEFT JOIN unit USING (unit_id)
LEFT JOIN variety USING (variety_id)
LEFT JOIN crop USING (crop_id)
GROUP BY harvest_id;

PRAGMA user_version = 3;

COMMIT;

PRAGMA foreign_keys = ON;
