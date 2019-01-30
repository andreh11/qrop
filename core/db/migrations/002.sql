-- 002
-- * location: add greenhouse boolean column

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

ALTER TABLE location
ADD COLUMN greenhouse INTEGER NOT NULL CHECK (greenhouse IN (0, 1)) DEFAULT 0;

PRAGMA user_version = 2;

COMMIT;

PRAGMA foreign_keys = ON;
