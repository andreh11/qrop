-- 009
-- add view for template tasks

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

CREATE VIEW IF NOT EXISTS template_task_view AS
SELECT task.task_id as template_task_view_id, task.*,
	task_type.type,
	task_method.method,
	task_implement.implement
FROM task
LEFT JOIN task_type using(task_type_id)
LEFT JOIN task_method using (task_method_id)
LEFT JOIN task_implement using (task_implement_id);

PRAGMA user_version = 9;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;

