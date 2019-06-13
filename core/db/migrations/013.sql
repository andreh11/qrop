-- 012
-- add is_default column to seed_company table 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE TABLE seed_company_new (
    seed_company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    seed_company    TEXT UNIQUE NOT NULL,
    is_default      INTEGER DEFAULT 0 NOT NULL
);

INSERT INTO seed_company_new (seed_company_id, seed_company)
SELECT * FROM seed_company;

DROP TABLE seed_company;

ALTER TABLE seed_company_new RENAME TO seed_company;

PRAGMA user_version = 13;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
