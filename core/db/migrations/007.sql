-- 007
-- relax link_task_id constraint 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

DROP TRIGGER task_update_linked_tasks;

CREATE TABLE IF NOT EXISTS task_new (
    task_id            INTEGER PRIMARY KEY AUTOINCREMENT,
    assigned_date      TEXT NOT NULL,
    completed_date     TEXT,
    duration           INTEGER, -- days
    labor_time         TEXT, -- HH:MM
    description        TEXT,
    task_type_id       INTEGER NOT NULL REFERENCES task_type ON DELETE CASCADE,
    task_method_id     INTEGER REFERENCES task_method ON DELETE SET NULL,
    task_implement_id  INTEGER REFERENCES task_implement ON DELETE SET NULL,
    link_task_id       INTEGER REFERENCES task ON DELETE SET NULL,
    link_days          INTEGER, -- If negative, days before linked task. Otherwise,
                                -- days after. 0 : same day.
    template_date_type INTEGER, -- 0: Field sowing/planting, 1: GH start date,
                                -- 2: first harvest, 3: last harvest
    task_template_id   INTEGER REFERENCES task_template
);

INSERT INTO task_new
SELECT * FROM task;

DROP TABLE task;
ALTER TABLE task_new RENAME TO task;

CREATE TRIGGER task_update_linked_tasks AFTER UPDATE on task FOR EACH ROW
WHEN
  NEW.assigned_date != OLD.assigned_date
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.assigned_date, link_days || " days")
  WHERE link_task_id = NEW.task_id;
END;

PRAGMA user_version = 7;

COMMIT;

PRAGMA foreign_keys = ON;

