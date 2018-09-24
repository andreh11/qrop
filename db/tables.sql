CREATE TABLE IF NOT EXISTS family (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family    TEXT NOT NULL,
    color     TEXT
);

CREATE TABLE IF NOT EXISTS crop (
    crop_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    crop       TEXT NOT NULL,
    color      TEXT,
    family_id INTEGER NOT NULL REFERENCES family ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS variety (
    variety_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    variety         TEXT NOT NULL,
    crop_id         INTEGER NOT NULL REFERENCES crop ON DELETE CASCADE,
    seed_company_id INTEGER REFERENCES seed_company
);

CREATE TABLE IF NOT EXISTS seed_company (
    seed_company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seed_company    TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS unit (
    unit_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    unit TEXT       UNIQUE NOT NULL,
    conversion_rate FLOAT -- from unit to kilogram
);

CREATE TABLE IF NOT EXISTS keyword (
    keyword_id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword    TEXT UNIQUE NOT NULL,
    color      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS note (
    note_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    content    TEXT NOT NULL,
    date       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS file (
    file_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    filename   TEXT,
    data       BLOB
);

CREATE TABLE IF NOT EXISTS planting (
    planting_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    code              TEXT,
    planting_type     INTEGER NOT NULL, -- 1: DS, 2: TP raised, 3: TP bought
    dtt               INTEGER,
    dtm               INTEGER,
    harvest_window    INTEGER,
    length            INTEGER,
    rows              INTEGER,
    surface           INTEGER,
    spacing_rows      INTEGER,
    spacing_plants    INTEGER,
    plants_needed     INTEGER,
    fudge_factor      INTEGER,
    plants_to_start   INTEGER,
    tray_size         INTEGER,
    trays_to_start    FLOAT,
    yield_per_bed_m   FLOAT,
    yield_per_hectare FLOAT,
    seeds_per_hole    INTEGER,
    seeds_per_gram    INTEGER,
    seeds_number      INTEGER,
    seeds_quantity    FLOAT,
    variety_id        INTEGER NOT NULL REFERENCES variety
);

CREATE TABLE IF NOT EXISTS harvest (
    harvest_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    date         TEXT NOT NULL,
    time         TEXT NOT NULL,
    quantity     FLOAT NOT NULL,
    planting_id  INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    bed_length  INTEGER, -- meter
    bed_width   INTEGER, -- centimeter
    path_width  INTEGER, -- centimeter
    surface     INTEGER, -- square meter
    parent_id   INTEGER REFERENCES location ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS role (
    role_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user (
    user_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name  TEXT NOT NULL,
    email      TEXT,
    labor_rate FLOAT,
    role_id    INTEGER NOT NULL REFERENCES role
);

CREATE TABLE IF NOT EXISTS task_template (
    task_template_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name             TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS task (
    task_id            INTEGER PRIMARY KEY AUTOINCREMENT,
    assigned_date      TEXT,
    completed_date     TEXT,
    duration           INTEGER, -- days
    labor_time         TEXT, -- HH:MM
    description        TEXT,
    task_type_id       INTEGER NOT NULL REFERENCES task_type,
    task_method_id     INTEGER REFERENCES task_method,
    task_implement_id  INTEGER REFERENCES task_implement,
    link_task_id       INTEGER REFERENCES task,
    link_days          INTEGER, -- If negative, days before linked task. Otherwise,
                                -- days after. 0 : same day.
    template_date_type INTEGER, -- 0: Field sowing/planting, 1: GH start date,
                                -- 2: first harvest, 3: last harvest
    task_template_id   INTEGER REFERENCES task_template
);

CREATE TABLE IF NOT EXISTS task_type (
    task_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL
);

INSERT INTO task_type (type) values ("Direct sow"); -- 1
INSERT INTO task_type (type) values ("Greenhouse sow"); -- 2
INSERT INTO task_type (type) values ("Transplant"); -- 3

CREATE TABLE IF NOT EXISTS task_method (
    task_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
    method TEXT NOT NULL,
    task_type_id INTEGER NOT NULL REFERENCES task_type ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS task_implement (
    task_implement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    implement TEXT NOT NULL,
    task_method_id INTEGER NOT NULL REFERENCES task_method ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS expense_category (
    expense_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS input (
    input_id INTEGER PRIMARY KEY AUTOINCREMENT,
    input TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS expense (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    cost FLOAT,
    labor_cost FLOAT,
    description TEXT,
    expense_category_id INTEGER NOT NULL REFERENCES expense_category,
    input_id INTEGER REFERENCES input,
    task_id INTEGER REFERENCES task
);

-- Link tables

CREATE TABLE IF NOT EXISTS planting_keyword (
    planting_id   INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE,
    keyword_id    INTEGER NOT NULL REFERENCES keyword ON DELETE CASCADE,
    PRIMARY KEY (planting_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS planting_note (
    planting_id   INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE,
    note_id       INTEGER NOT NULL REFERENCES note ON DELETE CASCADE,
    PRIMARY KEY (planting_id, note_id)
);

CREATE TABLE IF NOT EXISTS planting_task (
    planting_id   INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE,
    task_id       INTEGER NOT NULL REFERENCES task ON DELETE CASCADE,
    PRIMARY KEY (planting_id, task_id)
);

-- A task is associated to at least 1 planting. If there is no more planting
-- associated to a task, we delete it.
CREATE TRIGGER planting_task_delete AFTER DELETE ON planting_task FOR EACH ROW
WHEN (SELECT COUNT(*) FROM planting_task WHERE task_id = OLD.task_id) = 0
BEGIN
  DELETE FROM task
  WHERE task_id = OLD.task_id;
END;

CREATE TRIGGER planting_update_date AFTER UPDATE ON planting FOR EACH ROW
WHEN NEW.dtt != OLD.dtt
     AND NEW.planting_type = 2
BEGIN
  UPDATE task
  SET link_days = NEW.dtt,
      assigned_date = date(assigned_date, link_days || " days")
  WHERE task_id in (select task_id from planting_task WHERE planting_id = NEW.planting_id)
        AND task_type_id = 3; -- transplant
END;

CREATE TRIGGER task_update_date AFTER UPDATE on task FOR EACH ROW
WHEN
  NEW.assigned_date != OLD.assigned_date
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.assigned_date, link_days || " days")
  WHERE link_task_id = NEW.task_id;
END;

CREATE TABLE IF NOT EXISTS planting_location (
    planting_id   INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE,
    location_id   INTEGER NOT NULL REFERENCES location ON DELETE CASCADE,
    length        INTEGER,
    surface       INTEGER,
    PRIMARY KEY (planting_id, location_id)
);

CREATE TABLE IF NOT EXISTS planting_expense (
       planting_id INTEGER NOT NULL REFERENCES planting ON DELETE CASCADE,
       expense_id INTEGER NOT NULL REFERENCES expense ON DELETE CASCADE,
       PRIMARY KEY (planting_id, expense_id)
);

CREATE TABLE IF NOT EXISTS location_expense (
       location_id INTEGER NOT NULL REFERENCES location ON DELETE CASCADE,
       expense_id INTEGER NOT NULL REFERENCES expense ON DELETE CASCADE,
       PRIMARY KEY (location_id, expense_id)
);

CREATE TABLE IF NOT EXISTS task_assignment (
       task_id   INTEGER NOT NULL REFERENCES task ON DELETE CASCADE,
       user_id   INTEGER NOT NULL REFERENCES user ON DELETE CASCADE,
       PRIMARY KEY (task_id, user_id)
);

CREATE TABLE IF NOT EXISTS task_note (
       task_id   INTEGER NOT NULL REFERENCES task ON DELETE CASCADE,
       note_id   INTEGER NOT NULL REFERENCES note ON DELETE CASCADE,
       PRIMARY KEY (task_id, note_id)
);

CREATE TABLE IF NOT EXISTS note_file (
       note_id   INTEGER NOT NULL REFERENCES note ON DELETE CASCADE,
       file_id   INTEGER NOT NULL REFERENCES file ON DELETE CASCADE,
       PRIMARY KEY (note_id, file_id)
);

CREATE TABLE IF NOT EXISTS expense_file (
       expense_id   INTEGER NOT NULL REFERENCES expense ON DELETE CASCADE,
       file_id      INTEGER NOT NULL REFERENCES file ON DELETE CASCADE,
       PRIMARY KEY (expense_id, file_id)
);

insert into family (family) values ("Solanaceae");

insert into crop (crop, family_id) values ("Tomato", 1);

insert into variety (variety, crop_id) values ("Apéro F1", 1);

insert into planting (planting_type, variety_id, dtt) values (2, 1, 10);
insert into planting (planting_type, variety_id) values (1, 1);
insert into planting (planting_type, variety_id) values (1, 1);

insert into task_type (type) values ("Weed");

insert into task (task_type_id, assigned_date) values (2, "2018-03-10");
insert into task (task_type_id, assigned_date, link_days, link_task_id) values (3, "2018-03-11", 1, 1);
insert into task (task_type_id) values (4);
insert into task (task_type_id) values (4);
insert into task (task_type_id) values (4);

insert into planting_task values (1, 1);
insert into planting_task values (1, 2);
insert into planting_task values (3, 2);
insert into planting_task values (1, 3);
insert into planting_task values (1, 4);
insert into planting_task values (1, 5);

