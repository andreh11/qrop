-- 010
-- add template_task_id column
-- remove assigned_date NULL constraint for template tasks

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

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
    task_template_id   INTEGER REFERENCES task_template ON DELETE SET NULL
);

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
    task_template_id   INTEGER REFERENCES task_template ON DELETE SET NULL,
    -- id of the template task from which the task was created
    template_task_id   INTEGER REFERENCES template_task
);

INSERT INTO task_new
SELECT * FROM task;

DROP TABLE task;
ALTER TABLE task_new RENAME TO task;

PRAGMA user_version = 10;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
