-- 014
-- add keywords to planting_view

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

DROP VIEW IF EXISTS planting_view;
CREATE VIEW planting_view AS
SELECT planting_id as planting_view_id,
       planting.*,
       planting.length*yield_per_bed_meter*average_price as bed_revenue,
       planting.surface/10000*yield_per_hectare*average_price as surface_revenue,
       family, family_id, family.color as family_color,
       family.interval as family_interval,
       crop, crop_id, crop.color as crop_color, variety,
       unit.abbreviation as unit,
       group_concat(location_id) as locations,
       group_concat(DISTINCT keyword_id) as keyword_ids,
       group_concat(DISTINCT keyword) as keywords,
       task.assigned_date as planned_planting_date,
       date(task.assigned_date, "-" || dtt || " days") as planned_sowing_date,
       date(task.assigned_date, dtm || " days") as planned_beg_harvest_date,
       date(task.assigned_date, (dtm + harvest_window) || " days") as planned_end_harvest_date,
       CASE
           WHEN task.completed_date IS NULL THEN task.assigned_date
           ELSE task.completed_date
       END planting_date,
       CASE
           WHEN task.completed_date IS NULL THEN date(task.assigned_date, "-" || dtt || " days")
           ELSE date(task.completed_date, "-" || dtt || " days")
       END sowing_date,
       CASE
           WHEN task.completed_date IS NULL THEN date(task.assigned_date, dtm || " days")
           ELSE date(task.completed_date, dtm || " days")
       END beg_harvest_date,
       CASE
           WHEN task.completed_date IS NULL THEN date(task.assigned_date, (dtm + harvest_window) || " days")
           ELSE date(task.completed_date, (dtm + harvest_window) || " days")
       END end_harvest_date,
       seed_company_id, seed_company,
       dense_rank() over (
         PARTITION BY crop_id, strftime('%Y', task.assigned_date)
         ORDER BY task.assigned_date)
       planting_rank
FROM planting
LEFT JOIN planting_location using(planting_id)
LEFT JOIN variety USING (variety_id)
LEFT JOIN seed_company USING (seed_company_id)
LEFT JOIN crop USING (crop_id)
LEFT JOIN family USING (family_id)
LEFT JOIN unit USING (unit_id)
LEFT JOIN planting_task USING (planting_id)
LEFT JOIN task USING (task_id)
LEFT JOIN planting_keyword using (planting_id)
LEFT JOIN keyword using (keyword_id)
WHERE (planting_type == 1 and task_type_id == 1) OR (planting_type != 1 AND task_type_id == 3)
GROUP BY planting_id;
 select crop, variety, keywords from planting_view;

PRAGMA user_version = 14;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
