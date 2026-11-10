BEGIN TRANSACTION;
CREATE TABLE achievement (
	id INTEGER NOT NULL, 
	character_id INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	description VARCHAR(500), 
	unlocked_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(character_id) REFERENCES character (id)
);
INSERT INTO "achievement" VALUES(1,1,'Первая кровь','Победить в первом матче','2025-01-12 10:00:00');
INSERT INTO "achievement" VALUES(2,1,'Ветеран','Достичь 40 уровня','2026-05-01 12:00:00');
INSERT INTO "achievement" VALUES(3,3,'Снайпер','100 убийств из лука','2026-03-15 18:00:00');
INSERT INTO "achievement" VALUES(4,2,'Маг-новичок','Выучить первое заклинание','2025-02-02 09:00:00');
CREATE TABLE character (
	id INTEGER NOT NULL, 
	player_id INTEGER NOT NULL, 
	guild_id INTEGER, 
	name VARCHAR(80) NOT NULL, 
	level INTEGER NOT NULL, 
	experience INTEGER NOT NULL, 
	health INTEGER NOT NULL, 
	mana INTEGER NOT NULL, 
	position_x FLOAT NOT NULL, 
	position_y FLOAT NOT NULL, 
	position_z FLOAT NOT NULL, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_character_level CHECK (level > 0), 
	CONSTRAINT ck_character_exp CHECK (experience >= 0), 
	CONSTRAINT ck_character_health CHECK (health >= 0), 
	CONSTRAINT ck_character_mana CHECK (mana >= 0), 
	FOREIGN KEY(player_id) REFERENCES player (id), 
	FOREIGN KEY(guild_id) REFERENCES guild (id), 
	UNIQUE (name)
);
INSERT INTO "character" VALUES(1,1,1,'ShadowKnight',42,158000,150,80,100.5,0.0,250.3,'2025-01-11 09:00:00');
INSERT INTO "character" VALUES(2,1,1,'ShadowMage',35,98000,90,200,105.0,0.0,251.0,'2025-02-01 10:00:00');
INSERT INTO "character" VALUES(3,2,2,'NovaStriker',38,120000,130,100,50.0,0.0,100.0,'2025-02-16 11:00:00');
INSERT INTO "character" VALUES(4,3,NULL,'RavenEye',20,25000,110,90,0.0,0.0,0.0,'2025-03-21 15:00:00');
INSERT INTO "character" VALUES(5,4,NULL,'FrostBite',1,0,100,100,0.0,0.0,0.0,'2025-04-06 08:00:00');
CREATE TABLE game_server (
	id INTEGER NOT NULL, 
	ip_address VARCHAR(45) NOT NULL, 
	port INTEGER NOT NULL, 
	region VARCHAR(40) NOT NULL, 
	status VARCHAR(20) NOT NULL, 
	max_players INTEGER NOT NULL, 
	current_players INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (ip_address)
);
INSERT INTO "game_server" VALUES(1,'10.10.0.1',7777,'EU-West','online',100,45);
INSERT INTO "game_server" VALUES(2,'10.10.0.2',7777,'EU-East','online',100,72);
INSERT INTO "game_server" VALUES(3,'10.10.0.3',7777,'US-East','maintenance',100,0);
CREATE TABLE guild (
	id INTEGER NOT NULL, 
	owner_id INTEGER NOT NULL, 
	name VARCHAR(80) NOT NULL, 
	description VARCHAR(500), 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(owner_id) REFERENCES player (id), 
	UNIQUE (name)
);
INSERT INTO "guild" VALUES(1,1,'Тени Севера','Гильдия опытных игроков','2025-01-15 10:00:00');
INSERT INTO "guild" VALUES(2,2,'Новая Заря','Молодая гильдия','2025-03-01 12:00:00');
CREATE TABLE inventory_item (
	character_id INTEGER NOT NULL, 
	item_id INTEGER NOT NULL, 
	quantity INTEGER NOT NULL, 
	slot INTEGER NOT NULL, 
	equipped BOOLEAN NOT NULL, 
	PRIMARY KEY (character_id, item_id), 
	CONSTRAINT ck_inventory_qty CHECK (quantity > 0), 
	CONSTRAINT ck_inventory_slot CHECK (slot >= 0), 
	FOREIGN KEY(character_id) REFERENCES character (id), 
	FOREIGN KEY(item_id) REFERENCES item (id)
);
INSERT INTO "inventory_item" VALUES(1,1,1,0,1);
INSERT INTO "inventory_item" VALUES(1,3,1,1,1);
INSERT INTO "inventory_item" VALUES(1,4,10,2,0);
INSERT INTO "inventory_item" VALUES(2,2,1,0,1);
INSERT INTO "inventory_item" VALUES(2,4,5,1,0);
INSERT INTO "inventory_item" VALUES(3,2,1,0,1);
INSERT INTO "inventory_item" VALUES(3,5,1,1,1);
INSERT INTO "inventory_item" VALUES(3,4,20,2,0);
INSERT INTO "inventory_item" VALUES(4,4,3,0,0);
CREATE TABLE item (
	id INTEGER NOT NULL, 
	type_id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	rarity VARCHAR(20) NOT NULL, 
	base_stats VARCHAR(500), 
	price NUMERIC(12, 2) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_item_price CHECK (price >= 0), 
	FOREIGN KEY(type_id) REFERENCES item_type (id)
);
INSERT INTO "item" VALUES(1,1,'Меч теней','эпический','+50 к атаке',15000);
INSERT INTO "item" VALUES(2,1,'Лук новы','редкий','+35 к атаке',8000);
INSERT INTO "item" VALUES(3,2,'Кираса стража','эпический','+40 к защите',12000);
INSERT INTO "item" VALUES(4,3,'Зелье лечения','обычный','Восстанавливает 50 HP',150);
INSERT INTO "item" VALUES(5,4,'Кольцо силы','редкий','+10 к силе',5000);
CREATE TABLE item_type (
	id INTEGER NOT NULL, 
	name VARCHAR(80) NOT NULL, 
	category VARCHAR(40) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (name)
);
INSERT INTO "item_type" VALUES(1,'Оружие','weapon');
INSERT INTO "item_type" VALUES(2,'Броня','armor');
INSERT INTO "item_type" VALUES(3,'Зелье','consumable');
INSERT INTO "item_type" VALUES(4,'Кольцо','accessory');
CREATE TABLE "match" (
	id INTEGER NOT NULL, 
	server_id INTEGER NOT NULL, 
	game_mode VARCHAR(40) NOT NULL, 
	map_name VARCHAR(80) NOT NULL, 
	start_time DATETIME NOT NULL, 
	end_time DATETIME, 
	winner_team VARCHAR(20), 
	PRIMARY KEY (id), 
	CONSTRAINT ck_match_period CHECK (end_time IS NULL OR end_time >= start_time), 
	FOREIGN KEY(server_id) REFERENCES game_server (id)
);
INSERT INTO "match" VALUES(1,1,'Deathmatch','Arena','2026-10-20 18:00:00','2026-10-20 18:15:00','red');
INSERT INTO "match" VALUES(2,1,'Capture the Flag','Fortress','2026-10-21 20:00:00','2026-10-21 20:25:00','blue');
INSERT INTO "match" VALUES(3,2,'Deathmatch','Arena','2026-10-22 19:00:00','2026-10-22 19:12:00','red');
INSERT INTO "match" VALUES(4,2,'Team Deathmatch','Desert','2026-10-23 21:00:00',NULL,NULL);
CREATE TABLE match_player (
	match_id INTEGER NOT NULL, 
	character_id INTEGER NOT NULL, 
	team VARCHAR(20) NOT NULL, 
	score INTEGER NOT NULL, 
	kills INTEGER NOT NULL, 
	deaths INTEGER NOT NULL, 
	PRIMARY KEY (match_id, character_id), 
	CONSTRAINT ck_mp_kills CHECK (kills >= 0), 
	CONSTRAINT ck_mp_deaths CHECK (deaths >= 0), 
	CONSTRAINT ck_mp_score CHECK (score >= 0), 
	FOREIGN KEY(match_id) REFERENCES "match" (id), 
	FOREIGN KEY(character_id) REFERENCES character (id)
);
INSERT INTO "match_player" VALUES(1,1,'red',25,15,3);
INSERT INTO "match_player" VALUES(1,3,'blue',10,5,10);
INSERT INTO "match_player" VALUES(2,1,'blue',15,8,4);
INSERT INTO "match_player" VALUES(2,2,'blue',12,6,5);
INSERT INTO "match_player" VALUES(2,3,'red',8,4,7);
INSERT INTO "match_player" VALUES(3,3,'red',30,18,2);
INSERT INTO "match_player" VALUES(3,4,'blue',5,2,12);
INSERT INTO "match_player" VALUES(4,1,'red',0,0,0);
CREATE TABLE player (
	id INTEGER NOT NULL, 
	username VARCHAR(64) NOT NULL, 
	email VARCHAR(120) NOT NULL, 
	password_hash VARCHAR(255) NOT NULL, 
	created_at DATETIME NOT NULL, 
	last_login DATETIME, 
	status VARCHAR(20) NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT ck_player_status CHECK (status IN ('активен','заблокирован','удалён')), 
	UNIQUE (username), 
	UNIQUE (email)
);
INSERT INTO "player" VALUES(1,'shadow','shadow@example.com','hash1','2025-01-10 12:00:00','2026-11-01 18:30:00','активен');
INSERT INTO "player" VALUES(2,'nova','nova@example.com','hash2','2025-02-15 09:15:00','2026-11-02 20:00:00','активен');
INSERT INTO "player" VALUES(3,'raven','raven@example.com','hash3','2025-03-20 14:40:00','2026-10-28 11:00:00','активен');
INSERT INTO "player" VALUES(4,'frost','frost@example.com','hash4','2025-04-05 08:00:00',NULL,'заблокирован');
CREATE TABLE session (
	id INTEGER NOT NULL, 
	player_id INTEGER NOT NULL, 
	token VARCHAR(128) NOT NULL, 
	ip_address VARCHAR(45), 
	created_at DATETIME NOT NULL, 
	expires_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(player_id) REFERENCES player (id), 
	UNIQUE (token)
);
INSERT INTO "session" VALUES(1,1,'tok_shadow_001','192.168.1.10','2026-11-01 18:30:00','2026-11-02 18:30:00');
INSERT INTO "session" VALUES(2,2,'tok_nova_001','192.168.1.11','2026-11-02 20:00:00','2026-11-03 20:00:00');
INSERT INTO "session" VALUES(3,3,'tok_raven_001','10.0.0.5','2026-10-28 11:00:00','2026-10-29 11:00:00');
CREATE INDEX ix_match_server ON "match" (server_id);
CREATE INDEX ix_character_player ON character (player_id);
CREATE INDEX ix_achievement_character ON achievement (character_id);
COMMIT;