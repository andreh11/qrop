-- 0005 
-- * add seeder tables
-- * change type of length, surface and seeds_per_gram in planting table

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS seeder (
    seeder_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS seeder_front_gear (
    seeder_front_gear_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT UNIQUE NOT NULL,
    seeder_id    INTEGER REFERENCES seeder ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS seeder_rear_gear (
    seeder_rear_gear_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT UNIQUE NOT NULL,
    seeder_id    INTEGER REFERENCES seeder ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS seeder_plate (
    seeder_plate_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT UNIQUE NOT NULL,
    seeder_id    INTEGER REFERENCES seeder ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS planting_new (
    planting_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    code              TEXT,
    planting_type     INTEGER NOT NULL, -- 1: DS, 2: TP raised, 3: TP bought
    in_greenhouse     INTEGER NOT NULL CHECK (in_greenhouse IN (0, 1)),
    dtt               INTEGER,
    dtm               INTEGER,
    harvest_window    INTEGER,
    length            FLOAT,
    rows              INTEGER,
    surface           FLOAT,
    spacing_rows      INTEGER,
    spacing_plants    INTEGER,
    plants_needed     INTEGER,
    estimated_gh_loss INTEGER,
    plants_to_start   INTEGER,
    tray_size         INTEGER,
    trays_to_start    FLOAT,
    yield_per_hectare FLOAT,
    seeds_per_hole    INTEGER,
    seeds_per_gram    FLOAT,
    seeds_number      INTEGER,
    seeds_quantity    FLOAT,
    seeds_percentage  INTEGER,
    variety_id        INTEGER NOT NULL REFERENCES variety,
    unit_id           INTEGER REFERENCES unit ON DELETE SET NULL,
    yield_per_bed_meter   FLOAT,
    average_price     FLOAT,
    seeder_id    	 INTEGER REFERENCES seeder ON DELETE SET NULL,
    seeder_front_gear_id INTEGER REFERENCES seeder_front_gear ON DELETE SET NULL,
    seeder_rear_gear_id  INTEGER REFERENCES seeder_rear_gear ON DELETE SET NULL,
    seeder_plate_id      INTEGER REFERENCES seeder_plate ON DELETE SET NULL
);

INSERT INTO planting_new (planting_id,
    code,
    planting_type,
    in_greenhouse,
    dtt,
    dtm,
    harvest_window,
    length,
    rows,
    surface,
    spacing_rows,
    spacing_plants,
    plants_needed,
    estimated_gh_loss,
    plants_to_start,
    tray_size,
    trays_to_start,
    yield_per_hectare,
    seeds_per_hole,
    seeds_per_gram,
    seeds_number,
    seeds_quantity,
    seeds_percentage,
    variety_id,
    unit_id,
    yield_per_bed_meter,
    average_price)
SELECT * FROM planting;

DROP TABLE planting;
ALTER TABLE planting_new RENAME TO planting;

PRAGMA user_version = 5;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
