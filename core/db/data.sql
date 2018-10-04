insert into family (family) values ("Solanaceae");

insert into crop (crop, family_id) values ("Tomato", 1);

insert into variety (variety, crop_id) values ("Apéro F1", 1);

insert into planting (planting_type, variety_id, planting_date, dtt) values (2, 1, "2018-02-01", 10);
insert into planting (planting_type, variety_id, planting_date) values (1, 1, "2018-05-05");
insert into planting (planting_type, variety_id, planting_date) values (1, 1, "2018-10-22");

insert into task_type (type) values ("Weed");

insert into task (task_type_id, assigned_date) values (2, "2018-03-10");
insert into task (task_type_id, assigned_date, link_days, link_task_id) values (3, "2018-03-11", 1, 1);
insert into task (task_type_id) values (4);
insert into task (task_type_id) values (4);
insert into task (task_type_id) values (4);

insert into planting_task values (1, 1);
insert into planting_task values (1, 2);
insert into planting_task values (3, 2);
insert into planting_task values (1, 3);
insert into planting_task values (1, 4);
insert into planting_task values (1, 5);

insert into planting_location (planting_id, location_id, length) values (1, 1, 30);
insert into planting_location (planting_id, location_id, length) values (1, 2, 30);
