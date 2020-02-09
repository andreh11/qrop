-- 018
-- add record_view 

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE VIEW record_view AS
    SELECT note_id AS record_id, 
           date, 
           "note" AS type, 
           content AS details, 
           planting_id AS plantings, 
           location_id AS locations
    FROM note_view
UNION
    SELECT task_id AS record_id, 
           completed_date AS date, 
           "task" AS type, 
           type AS details, 
           plantings, 
           locations 
    FROM task_view
    WHERE completed_date IS NOT NULL
UNION
    SELECT harvest_id AS record_id, 
           date, 
           "harvest" AS type, 
           quantity AS details, 
           planting_id AS plantings, 
           NULL AS locations
    FROM harvest;

PRAGMA user_version = 18;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
