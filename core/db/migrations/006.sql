-- 0006
-- * add note_view

PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS location_note (
    location_id   INTEGER NOT NULL REFERENCES location ON DELETE CASCADE,
    note_id       INTEGER NOT NULL REFERENCES note ON DELETE CASCADE,
    PRIMARY KEY (location_id, note_id)
);

CREATE VIEW IF NOT EXISTS note_view AS
SELECT note.*, planting_id, task_id, location_id FROM note
LEFT JOIN planting_note using (note_id)
LEFT JOIN task_note using (note_id)
LEFT JOIN location_note using (note_id);

PRAGMA user_version = 6;

COMMIT;

PRAGMA foreign_keys = ON;

