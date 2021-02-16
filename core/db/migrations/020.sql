-- 020
-- add 'delete' field for Tables seed_company, family, crop, variety

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

ALTER TABLE seed_company
ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT(0);

ALTER TABLE family
ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT(0);

ALTER TABLE crop
ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT(0);

ALTER TABLE variety
ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT(0);

PRAGMA user_version = 20;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
