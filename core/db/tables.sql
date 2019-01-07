CREATE TABLE IF NOT EXISTS family (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family    TEXT NOT NULL,
    interval  INTEGER NOT NULL DEFAULT 0,
    color     TEXT DEFAULT '#000000' NOT NULL
);

CREATE TABLE IF NOT EXISTS crop (
    crop_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    crop       TEXT NOT NULL,
    color      TEXT DEFAULT '#000000' NOT NULL,
    family_id  INTEGER NOT NULL REFERENCES family ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS variety (
    variety_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    variety         TEXT NOT NULL,
    crop_id         INTEGER NOT NULL REFERENCES crop ON DELETE CASCADE,
    seed_company_id INTEGER REFERENCES seed_company ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS seed_company (
    seed_company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seed_company    TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS unit (
    unit_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    fullname TEXT   UNIQUE NOT NULL,
    abbreviation TEXT UNIQUE NOT NULL,
    conversion_rate FLOAT -- from unit to kilogram
);

INSERT INTO unit values (1, "kilogram", "kg", 1.0);
INSERT INTO unit values (2, "bunch", "bn", 1.0);

CREATE TABLE IF NOT EXISTS keyword (
    keyword_id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword    TEXT UNIQUE NOT NULL,
    color      TEXT
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
    in_greenhouse     INTEGER NOT NULL CHECK (in_greenhouse IN (0, 1)),
    dtt               INTEGER,
    dtm               INTEGER,
    harvest_window    INTEGER,
    length            INTEGER,
    rows              INTEGER,
    surface           INTEGER,
    spacing_rows      INTEGER,
    spacing_plants    INTEGER,
    plants_needed     INTEGER,
    estimated_gh_loss INTEGER,
    plants_to_start   INTEGER,
    tray_size         INTEGER,
    trays_to_start    FLOAT,
    yield_per_hectare FLOAT,
    seeds_per_hole    INTEGER,
    seeds_per_gram    INTEGER,
    seeds_number      INTEGER,
    seeds_quantity    FLOAT,
    seeds_percentage  INTEGER,
    variety_id        INTEGER NOT NULL REFERENCES variety,
    unit_id           INTEGER REFERENCES unit ON DELETE SET NULL,
    yield_per_bed_meter   FLOAT,
    average_price     FLOAT
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
    role    TEXT UNIQUE NOT NULL
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
    assigned_date      TEXT NOT NULL,
    completed_date     TEXT,
    duration           INTEGER, -- days
    labor_time         TEXT, -- HH:MM
    description        TEXT,
    task_type_id       INTEGER NOT NULL REFERENCES task_type ON DELETE CASCADE,
    task_method_id     INTEGER REFERENCES task_method ON DELETE SET NULL,
    task_implement_id  INTEGER REFERENCES task_implement ON DELETE SET NULL,
    link_task_id       INTEGER REFERENCES task,
    link_days          INTEGER, -- If negative, days before linked task. Otherwise,
                                -- days after. 0 : same day.
    template_date_type INTEGER, -- 0: Field sowing/planting, 1: GH start date,
                                -- 2: first harvest, 3: last harvest
    task_template_id   INTEGER REFERENCES task_template
);

CREATE TABLE IF NOT EXISTS task_type (
    task_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type         TEXT UNIQUE NOT NULL,
    color        TEXT DEFAULT '#000000' NOT NULL
);

INSERT INTO task_type (task_type_id, type) values (1, "Direct sow");
INSERT INTO task_type (task_type_id, type) values (2, "Greenhouse sow");
INSERT INTO task_type (task_type_id, type) values (3, "Transplant");

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
    category TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS input (
    input_id INTEGER PRIMARY KEY AUTOINCREMENT,
    input TEXT UNIQUE NOT NULL
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

CREATE TABLE IF NOT EXISTS location_task (
    location_id   INTEGER NOT NULL REFERENCES location ON DELETE CASCADE,
    task_id       INTEGER NOT NULL REFERENCES task ON DELETE CASCADE,
    PRIMARY KEY (location_id, task_id)
);

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

-- Views

CREATE VIEW IF NOT EXISTS planting_view AS
SELECT planting_id as planting_view_id,
       family, family_id, family.color as family_color, family.interval as family_interval,
       crop, variety, variety_id, crop_id, crop.color as crop_color,
       planting.*,
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

CREATE VIEW IF NOT EXISTS variety_view AS
SELECT variety.*, seed_company, variety || ' (' || seed_company || ')' as variety_and_company
FROM variety
LEFT JOIN seed_company USING (seed_company_id);

CREATE VIEW IF NOT EXISTS task_view AS
SELECT task.task_id as task_view_id, task.*, task_type.type, task_method.method, task_implement.implement, group_concat(planting_id) as plantings, group_concat(location_id) as locations
FROM task
LEFT JOIN planting_task using(task_id)
LEFT JOIN location_task using(task_id)
LEFT JOIN task_type using(task_type_id)
LEFT JOIN task_method using (task_method_id)
LEFT JOIN task_implement using (task_implement_id)
GROUP BY task_id;

