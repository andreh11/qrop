-- 018
-- add finished column to planting 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS finished_reason (
    finished_reason_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reason TEXT NOT NULL
);

ALTER TABLE planting
ADD COLUMN finished BOOLEAN;

ALTER TABLE planting
ADD COLUMN finished_reason_id  INTEGER REFERENCES finished_reason ON DELETE SET NULL;


PRAGMA user_version = 19;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
