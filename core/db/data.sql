insert into family (family) values ("Alliaceae");
insert into family (family) values ("Apiaceae");
insert into family (family) values ("Asteraceae");
insert into family (family) values ("Brassicaceae");
insert into family (family) values ("Chenopodiaceae");
insert into family (family) values ("Cucurbitaceae");
insert into family (family) values ("Fabaceae");
insert into family (family) values ("Solanaceae");
insert into family (family) values ("Valerianaceae");

insert into crop (crop, family_id) values ("Tomato", 1);
insert into crop (crop, family_id) values ("Pepper", 1);
insert into crop (crop, family_id) values ("Potato", 1);
insert into crop (crop, family_id) values ("Eggplant", 1);

insert into seed_company (seed_company) values ("Unknown company");
insert into seed_company (seed_company) values ("Agrosemens");
insert into seed_company (seed_company) values ("Essembio");
insert into seed_company (seed_company) values ("Voltz");
insert into seed_company (seed_company) values ("Gautier");
insert into seed_company (seed_company) values ("Sativa");

insert into variety (variety, crop_id) values ("Apéro F1", 1);
insert into variety (variety, crop_id) values ("Cindel F1", 1);
insert into variety (variety, crop_id) values ("Marnero F1", 1);
insert into variety (variety, crop_id) values ("Marbonne F1", 1);
insert into variety (variety, crop_id) values ("Sprinter F1", 2);
insert into variety (variety, crop_id) values ("Yolo Wonder", 2);
insert into variety (variety, crop_id) values ("Amandine", 3);
insert into variety (variety, crop_id) values ("Nicola", 3);

insert into task_type (type) values ("Weed");

INSERT INTO keyword VALUES(1,'paillage plastique','#897643');
INSERT INTO keyword VALUES(2,'P30','#597643');
INSERT INTO keyword VALUES(3,'P17','');
INSERT INTO keyword VALUES(4,'Bâche tissée','');
INSERT INTO keyword VALUES(5,'Filbio','');
