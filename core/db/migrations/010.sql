-- 010
-- add template_task_id column
-- add template_task table
-- remove assigned_date NULL constraint for template tasks
-- add surface_revenue and bed_revenue to planting_view
-- add planting_rank to planting_view

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

DROP VIEW planting_view;
CREATE VIEW IF NOT EXISTS planting_view AS
SELECT planting_id as planting_view_id,
       planting.*,
       planting.length*yield_per_bed_meter*average_price as bed_revenue,
       planting.surface/10000*yield_per_hectare*average_price as surface_revenue,
       family, family_id, family.color as family_color,
       family.interval as family_interval,
       crop, crop_id, crop.color as crop_color, variety,
       unit.abbreviation as unit,
       group_concat(location_id) as locations,
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
       -- date(task.assigned_date, "-" || dtt || " days") as sowing_date,
       -- date(task.assigned_date, dtm || " days") as beg_harvest_date,
       -- date(task.assigned_date, (dtm + harvest_window) || " days") as end_harvest_date,
       seed_company_id, seed_company,
       dense_rank() over (
         partition by crop_id, strftime('%Y', task.assigned_date)
         order by task.assigned_date)
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
WHERE (planting_type == 1 and task_type_id == 1) OR (planting_type != 1 AND task_type_id == 3)
GROUP BY planting_id;

CREATE TABLE IF NOT EXISTS template_task (
    template_task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    duration           INTEGER, -- days in field
    description        TEXT,
    task_type_id       INTEGER NOT NULL REFERENCES task_type ON DELETE CASCADE,
    task_method_id     INTEGER REFERENCES task_method ON DELETE SET NULL,
    task_implement_id  INTEGER REFERENCES task_implement ON DELETE SET NULL,
    -- If negative, days before linked task. Otherwise, days after. 0 : same day.
    link_days          INTEGER,
    -- 0: Field sowing/planting, 1: GH start date, 2: first harvest, 3: last harvest
    template_date_type INTEGER NOT NULL,
    task_template_id   INTEGER REFERENCES task_template ON DELETE CASCADE
);

DROP VIEW IF EXISTS template_task_view;
CREATE VIEW template_task_view AS
SELECT template_task.template_task_id as template_task_view_id,
    template_task.*,
    task_type.type,
    task_method.method,
    task_implement.implement
FROM template_task
LEFT JOIN task_type using(task_type_id)
LEFT JOIN task_method using (task_method_id)
LEFT JOIN task_implement using (task_implement_id);

CREATE TABLE IF NOT EXISTS task_new (
    task_id            INTEGER PRIMARY KEY AUTOINCREMENT,
    assigned_date      TEXT NOT NULL,
    completed_date     TEXT,
    duration           INTEGER, -- days in field
    labor_time         TEXT, -- HH:MM
    description        TEXT,
    task_type_id       INTEGER NOT NULL REFERENCES task_type ON DELETE CASCADE,
    task_method_id     INTEGER REFERENCES task_method ON DELETE SET NULL,
    task_implement_id  INTEGER REFERENCES task_implement ON DELETE SET NULL,
    link_task_id       INTEGER REFERENCES task ON DELETE SET NULL,
    -- If negative, days before linked task. Otherwise, days after. 0: same day.
    link_days          INTEGER,
    -- 0: Field sowing/planting, 1: GH start date, -- 2: first harvest, 3: last harvest
    template_date_type INTEGER,
    -- id of the template task from which the task was created
    template_task_id   INTEGER REFERENCES template_task ON DELETE SET NULL
);

INSERT INTO task_new
SELECT
  task_id,
  assigned_date,
  completed_date,
  duration,
  labor_time,
  description,
  task_type_id,
  task_method_id,
  task_implement_id,
  link_task_id,
  link_days,
  template_date_type,
  NULL
FROM task;

DROP TABLE task;
ALTER TABLE task_new RENAME TO task;

DROP VIEW IF EXISTS task_view;
CREATE VIEW task_view AS
SELECT task.task_id AS task_view_id, task.*,
       task_template_id,
       task_type.type, task_method.method, task_implement.implement,
       group_concat(planting_id) AS plantings,
       NULL AS locations
FROM task
JOIN planting_task USING (task_id)
LEFT JOIN template_task USING (template_task_id)
LEFT JOIN task_type USING (task_type_id)
LEFT JOIN task_method USING (task_method_id)
LEFT JOIN task_implement USING (task_implement_id)
GROUP BY task_id
UNION ALL
SELECT task.task_id AS task_view_id, task.*,
       task_template_id,
       task_type.type, task_method.method, task_implement.implement,
       NULL AS plantings,
       group_concat(location_id) AS locations
FROM task
JOIN location_task USING (task_id)
LEFT JOIN template_task USING (template_task_id)
LEFT JOIN task_type USING (task_type_id)
LEFT JOIN task_method USING (task_method_id)
LEFT JOIN task_implement USING (task_implement_id)
GROUP BY task_id;

DROP TRIGGER IF EXISTS task_update_linked_tasks;
CREATE TRIGGER task_update_linked_tasks AFTER UPDATE on task FOR EACH ROW
WHEN
  NEW.assigned_date != OLD.assigned_date
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.assigned_date, link_days || " days")
  WHERE link_task_id = NEW.task_id
  AND completed_date IS NULL;
END;

CREATE TRIGGER task_completed_update_linked_tasks AFTER UPDATE on task FOR EACH ROW
WHEN
  (NEW.completed_date IS NOT NULL) AND (OLD.completed_date IS NULL)
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.completed_date, link_days || " days")
  WHERE link_task_id = NEW.task_id
  AND completed_date IS NULL;
END;

CREATE TRIGGER task_uncompleted_update_linked_tasks AFTER UPDATE on task FOR EACH ROW
WHEN
  (NEW.completed_date IS NULL) AND (OLD.completed_date IS NOT NULL)
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.assigned_date, link_days || " days")
  WHERE link_task_id = NEW.task_id
  AND completed_date IS NULL;
END;

PRAGMA user_version = 10;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
