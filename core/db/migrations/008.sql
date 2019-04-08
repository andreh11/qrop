-- 008
-- remove redundant column variety_id:1 from planting_view 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

DROP VIEW planting_view;

CREATE VIEW IF NOT EXISTS planting_view AS
SELECT planting_id as planting_view_id,
       planting.*,
       family, family_id, family.color as family_color,
       family.interval as family_interval,
       crop, crop_id, crop.color as crop_color, variety,
       unit.abbreviation as unit,
       group_concat(location_id) as locations,
       task.assigned_date as planting_date,
       date(task.assigned_date, "-" || dtt || " days") as sowing_date,
       date(task.assigned_date, dtm || " days") as beg_harvest_date,
       date(task.assigned_date, (dtm + harvest_window) || " days") as end_harvest_date,
       seed_company_id, seed_company
FROM planting
LEFT JOIN planting_location using(planting_id)
LEFT JOIN variety USING (variety_id)
LEFT JOIN seed_company USING (seed_company_id)
LEFT JOIN crop USING (crop_id)
LEFT JOIN family USING (family_id)
LEFT JOIN unit USING (unit_id)
LEFT JOIN planting_task USING (planting_id)
LEFT JOIN task USING (task_id)
WHERE (planting_type == 1 and task_type_id == 1) OR (planting_type != 1 AND task_type_id == 3)
GROUP BY planting_id;

PRAGMA user_version = 8;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;

