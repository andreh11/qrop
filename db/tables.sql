CREATE TABLE IF NOT EXISTS family (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family      TEXT NOT NULL,
    color     TEXT
);

CREATE TABLE IF NOT EXISTS crop (
    crop_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    crop       TEXT NOT NULL,
    color      TEXT,
    family_id INTEGER REFERENCES family(family_id)
);

CREATE TABLE IF NOT EXISTS variety (
    variety_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    variety         TEXT NOT NULL,
    crop_id         INTEGER REFERENCES crop(crop_id),
    seed_company_id INTEGER REFERENCES seed_company(seed_company_id)
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
    planting_type     TEXT,
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
    variety_id        INTEGER NOT NULL REFERENCES variety(variety_id)
);

CREATE TABLE IF NOT EXISTS harvest (
    harvest_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    date         TEXT NOT NULL,
    time         TEXT NOT NULL,
    quantity     FLOAT NOT NULL,
    planting_id  INTEGER NOT NULL REFERENCES planting(planting_id)
);

CREATE TABLE IF NOT EXISTS location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    bed_length  INTEGER, -- meter
    bed_width   INTEGER, -- centimeter
    path_width  INTEGER, -- centimeter
    surface     INTEGER, -- square meter
    parent_id   INTEGER NOT NULL REFERENCES location(location_id)
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
    role_id    INTEGER NOT NULL REFERENCES role(role_id)
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
    task_type_id       INTEGER NOT NULL REFERENCES task_type(task_type_id),
    task_method_id     INTEGER NOT NULL REFERENCES task_method(task_method_id),
    task_implement_id  INTEGER NOT NULL REFERENCES task_implement(task_implement_id),
    link_task_id       INTEGER REFERENCES task(task_id),
    link_days          INTEGER, -- If negative, days before linked task. Otherwise,
                                -- days after. 0 : same day.
    template_date_type INTEGER, -- 0: Field sowing/planting, 1: GH start date,
                                -- 2: first harvest, 3: last harvest
    task_template_id   INTEGER REFERENCES task_template(task_template_id)
);

CREATE TABLE IF NOT EXISTS task_type (
    task_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS task_method (
    task_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
    method TEXT NOT NULL,
    task_type_id INTEGER NOT NULL REFERENCES task_type(task_type_id)
);

CREATE TABLE IF NOT EXISTS task_implement (
    task_implement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    implement TEXT NOT NULL,
    task_method_id INTEGER NOT NULL REFERENCES task_method(task_method_id)
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
    expense_category_id INTEGER NOT NULL REFERENCES expense_category(expense_category_id),
    input_id INTEGER REFERENCES input(input_id),
    task_id INTEGER REFERENCES task(task_id)
);

-- Link tables

CREATE TABLE IF NOT EXISTS planting_keyword (
    planting_id   INTEGER NOT NULL REFERENCES planting,
    keyword_id    INTEGER NOT NULL REFERENCES keyword,
    PRIMARY KEY (planting_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS planting_note (
    planting_id   INTEGER NOT NULL REFERENCES planting,
    note_id       INTEGER NOT NULL REFERENCES note,
    PRIMARY KEY (planting_id, note_id)
);

CREATE TABLE IF NOT EXISTS planting_task (
    planting_id   INTEGER NOT NULL REFERENCES planting,
    task_id       INTEGER NOT NULL REFERENCES task,
    PRIMARY KEY (planting_id, task_id)
);

CREATE TABLE IF NOT EXISTS planting_task_template (
    planting_id   INTEGER NOT NULL REFERENCES planting,
    task_template_id       INTEGER NOT NULL REFERENCES task_template,
    PRIMARY KEY (planting_id, task_template_id)
);

CREATE TABLE IF NOT EXISTS planting_location (
    planting_id   INTEGER NOT NULL REFERENCES planting(planting_id),
    location_id   INTEGER NOT NULL REFERENCES location(location_id),
    length        INTEGER,
    surface       INTEGER,
    PRIMARY KEY (planting_id, location_id)
);

CREATE TABLE IF NOT EXISTS planting_expense (
    planting_id INTEGER NOT NULL REFERENCES planting,
    expense_id INTEGER NOT NULL REFERENCES expense,
    PRIMARY KEY (planting_id, expense_id)
);

CREATE TABLE IF NOT EXISTS task_assignment (
    task_id   INTEGER NOT NULL REFERENCES task,
    user_id   INTEGER NOT NULL REFERENCES user,
    PRIMARY KEY (task_id, user_id)
);

CREATE TABLE IF NOT EXISTS task_note (
    task_id   INTEGER NOT NULL REFERENCES task,
    note_id   INTEGER NOT NULL REFERENCES note,
    PRIMARY KEY (task_id, note_id)
);

CREATE TABLE IF NOT EXISTS note_file (
    note_id   INTEGER NOT NULL REFERENCES note,
    file_id   INTEGER NOT NULL REFERENCES file,
    PRIMARY KEY (note_id, file_id)
);

CREATE TABLE IF NOT EXISTS expense_file (
    expense_id   INTEGER NOT NULL REFERENCES expense,
    file_id      INTEGER NOT NULL REFERENCES file,
    PRIMARY KEY (expense_id, file_id)
);
