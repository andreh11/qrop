-- 016
-- add color to task_view

PRAGMA foreign_keys = OFF;
PRAGMA legacy_alter_table = 1;

BEGIN TRANSACTION;

DROP VIEW IF EXISTS task_view;

CREATE VIEW task_view AS
SELECT task.task_id AS task_view_id, task.*,
       task_template_id,
       task_type.type, task_type.color AS color,
       task_method.method, task_implement.implement,
       group_concat(planting_id) AS plantings,
       NULL AS locations
FROM task
JOIN planting_task USING (task_id)
LEFT JOIN template_task USING (template_task_id)
LEFT JOIN task_type USING (task_type_id)
LEFT JOIN task_method USING (task_method_id)
LEFT JOIN task_implement USING (task_implement_id)
GROUP BY task_id
UNION ALL
SELECT task.task_id AS task_view_id, task.*,
       task_template_id,
       task_type.type, task_type.color AS color,
       task_method.method, task_implement.implement,
       NULL AS plantings,
       group_concat(location_id) AS locations
FROM task
JOIN location_task USING (task_id)
LEFT JOIN template_task USING (template_task_id)
LEFT JOIN task_type USING (task_type_id)
LEFT JOIN task_method USING (task_method_id)
LEFT JOIN task_implement USING (task_implement_id)
GROUP BY task_id;

PRAGMA user_version = 16;

COMMIT;

PRAGMA foreign_keys = ON;
PRAGMA legacy_alter_table = 0;
