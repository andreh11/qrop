-- 012
-- add is_default column to varity table 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE TABLE variety_new (
    variety_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    variety         TEXT NOT NULL,
    crop_id         INTEGER NOT NULL REFERENCES crop ON DELETE CASCADE,
    seed_company_id INTEGER REFERENCES seed_company ON DELETE SET NULL,
    is_default      INTEGER DEFAULT 0 NOT NULL
);

INSERT INTO variety_new (variety_id, variety, crop_id, seed_company_id)
SELECT * FROM variety;

DROP TABLE variety;

ALTER TABLE variety_new RENAME TO variety;

PRAGMA user_version = 12;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
