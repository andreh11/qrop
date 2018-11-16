-- Triggers

-- A task is associated to at least 1 planting. If there is no more planting
-- associated to a task, we delete it.
CREATE TRIGGER planting_task_delete AFTER DELETE ON planting_task FOR EACH ROW
WHEN (SELECT COUNT(*) FROM planting_task WHERE task_id = OLD.task_id) = 0
BEGIN
  DELETE FROM task
  WHERE task_id = OLD.task_id;
END;

-- If the dtt of TP, raised planting if modified, update linked transplant task.
CREATE TRIGGER planting_update_dtt AFTER UPDATE ON planting FOR EACH ROW
WHEN NEW.dtt != OLD.dtt
     AND NEW.planting_type = 2 -- transplant, raised
BEGIN
  UPDATE task
  SET link_days = NEW.dtt,
      assigned_date = date(assigned_date, NEW.dtt || " days")
  WHERE task_id in (select task_id from planting_task WHERE planting_id = NEW.planting_id)
  AND task_type_id = 3; -- transplant
END;

-- CREATE TRIGGER task_update_gh_sow_date AFTER UPDATE on task FOR EACH ROW
-- WHEN task_type_id = 2
-- AND NEW.assigned_date != OLD.assigned_date
-- BEGIN
--   UPDATE planting
--   SET dtt = NEW.assigned_date
--   WHERE planting_id in (SELECT planting_id FROM planting_task WHERE task_id = NEW.task_id);
-- END;

CREATE TRIGGER task_update_linked_tasks AFTER UPDATE on task FOR EACH ROW
WHEN
  NEW.assigned_date != OLD.assigned_date
BEGIN
  UPDATE task
  SET assigned_date = date(NEW.assigned_date, link_days || " days")
  WHERE link_task_id = NEW.task_id;
END;
