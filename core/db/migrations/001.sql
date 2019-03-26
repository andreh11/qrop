-- 0001
-- * location: change bed_width type from INTEGER to FLOAT

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS location_new (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    bed_length  INTEGER, -- meter
    bed_width   FLOAT, -- meter
    path_width  INTEGER, -- centimeter
    surface     INTEGER, -- square meter
    parent_id   INTEGER REFERENCES location ON DELETE CASCADE
);

INSERT INTO location_new SELECT * FROM location;
DROP TABLE location;
ALTER TABLE location_new RENAME TO location;

PRAGMA user_version = 1;

COMMIT;

PRAGMA foreign_keys = ON;
