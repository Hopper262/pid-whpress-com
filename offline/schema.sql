drop table if exists slot;
create table slot (
	id int unsigned primary key auto_increment,
	added timestamp default current_timestamp,
	display_id varchar(32) not null,
	name varchar(128),
	author varchar(128),
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	level tinyint unsigned,
	elapsed int unsigned,
	points int unsigned,
	treasure int unsigned,
	pstate_id int unsigned
);
alter table slot add unique key (display_id);

drop table if exists defaultslot;
create table defaultslot (
	added timestamp default current_timestamp,
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	slot_id int unsigned
);
alter table defaultslot add primary key (game, slot_id);

drop table if exists slot_lstate;
create table slot_lstate (
	added timestamp default current_timestamp,
	slot_id int unsigned,
	lstate_id int unsigned,
	level tinyint unsigned
);
alter table slot_lstate add primary key (slot_id, lstate_id);

drop table if exists pstate;
create table pstate (
	id int unsigned primary key auto_increment,
	added timestamp default current_timestamp,
	crc int unsigned,
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	level tinyint unsigned,
	elapsed int unsigned,
	points int unsigned,
	treasure int unsigned,
	data longblob,
	json longtext
);

drop table if exists lstate;
create table lstate (
	id int unsigned primary key auto_increment,
	added timestamp default current_timestamp,
	crc int unsigned,
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	level tinyint unsigned,
	map_id int unsigned,
	explored boolean,
	image_id int unsigned,
	data longblob,
	json longtext
);

drop table if exists map;
create table map (
	id int unsigned primary key auto_increment,
	added timestamp default current_timestamp,
	crc int unsigned,
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	level tinyint unsigned,
	image_id int unsigned,
	name varchar(128),
	elevation decimal(5,1),
	data longblob,
	json longtext
);
alter table map add unique key (game, level);

drop table if exists image;
create table image (
	id int unsigned primary key auto_increment,
	added timestamp default current_timestamp,
	crc int unsigned,
	game enum('full11', 'full20', 'demoA1', 'demo20'),
	level tinyint unsigned,
	width smallint unsigned,
	height smallint unsigned,
	content_type varchar(64),
	data longblob
);
	
