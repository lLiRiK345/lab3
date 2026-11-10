-- Минимальный набор тестовых данных для отладки запросов (лабораторная работа №3)
-- Многопользовательская игра. Данные вымышленные.

INSERT INTO player (id, username, email, password_hash, created_at, last_login, status) VALUES
 (1,'shadow','shadow@example.com','hash1','2025-01-10 12:00:00','2026-11-01 18:30:00','активен'),
 (2,'nova','nova@example.com','hash2','2025-02-15 09:15:00','2026-11-02 20:00:00','активен'),
 (3,'raven','raven@example.com','hash3','2025-03-20 14:40:00','2026-10-28 11:00:00','активен'),
 (4,'frost','frost@example.com','hash4','2025-04-05 08:00:00',NULL,'заблокирован');

INSERT INTO session (id, player_id, token, ip_address, created_at, expires_at) VALUES
 (1,1,'tok_shadow_001','192.168.1.10','2026-11-01 18:30:00','2026-11-02 18:30:00'),
 (2,2,'tok_nova_001','192.168.1.11','2026-11-02 20:00:00','2026-11-03 20:00:00'),
 (3,3,'tok_raven_001','10.0.0.5','2026-10-28 11:00:00','2026-10-29 11:00:00');

INSERT INTO guild (id, owner_id, name, description, created_at) VALUES
 (1,1,'Тени Севера','Гильдия опытных игроков','2025-01-15 10:00:00'),
 (2,2,'Новая Заря','Молодая гильдия','2025-03-01 12:00:00');

INSERT INTO character (id, player_id, guild_id, name, level, experience, health, mana, position_x, position_y, position_z, created_at) VALUES
 (1,1,1,'ShadowKnight',42,158000,150,80,100.5,0.0,250.3,'2025-01-11 09:00:00'),
 (2,1,1,'ShadowMage',35,98000,90,200,105.0,0.0,251.0,'2025-02-01 10:00:00'),
 (3,2,2,'NovaStriker',38,120000,130,100,50.0,0.0,100.0,'2025-02-16 11:00:00'),
 (4,3,NULL,'RavenEye',20,25000,110,90,0.0,0.0,0.0,'2025-03-21 15:00:00'),
 (5,4,NULL,'FrostBite',1,0,100,100,0.0,0.0,0.0,'2025-04-06 08:00:00');

INSERT INTO item_type (id, name, category) VALUES
 (1,'Оружие','weapon'),(2,'Броня','armor'),(3,'Зелье','consumable'),(4,'Кольцо','accessory');

INSERT INTO item (id, type_id, name, rarity, base_stats, price) VALUES
 (1,1,'Меч теней','эпический','+50 к атаке',15000.00),
 (2,1,'Лук новы','редкий','+35 к атаке',8000.00),
 (3,2,'Кираса стража','эпический','+40 к защите',12000.00),
 (4,3,'Зелье лечения','обычный','Восстанавливает 50 HP',150.00),
 (5,4,'Кольцо силы','редкий','+10 к силе',5000.00);

INSERT INTO inventory_item (character_id, item_id, quantity, slot, equipped) VALUES
 (1,1,1,0,1),(1,3,1,1,1),(1,4,10,2,0),
 (2,2,1,0,1),(2,4,5,1,0),
 (3,2,1,0,1),(3,5,1,1,1),(3,4,20,2,0),
 (4,4,3,0,0);

INSERT INTO achievement (id, character_id, name, description, unlocked_at) VALUES
 (1,1,'Первая кровь','Победить в первом матче','2025-01-12 10:00:00'),
 (2,1,'Ветеран','Достичь 40 уровня','2026-05-01 12:00:00'),
 (3,3,'Снайпер','100 убийств из лука','2026-03-15 18:00:00'),
 (4,2,'Маг-новичок','Выучить первое заклинание','2025-02-02 09:00:00');

INSERT INTO game_server (id, ip_address, port, region, status, max_players, current_players) VALUES
 (1,'10.10.0.1',7777,'EU-West','online',100,45),
 (2,'10.10.0.2',7777,'EU-East','online',100,72),
 (3,'10.10.0.3',7777,'US-East','maintenance',100,0);

INSERT INTO match (id, server_id, game_mode, map_name, start_time, end_time, winner_team) VALUES
 (1,1,'Deathmatch','Arena','2026-10-20 18:00:00','2026-10-20 18:15:00','red'),
 (2,1,'Capture the Flag','Fortress','2026-10-21 20:00:00','2026-10-21 20:25:00','blue'),
 (3,2,'Deathmatch','Arena','2026-10-22 19:00:00','2026-10-22 19:12:00','red'),
 (4,2,'Team Deathmatch','Desert','2026-10-23 21:00:00',NULL,NULL);

INSERT INTO match_player (match_id, character_id, team, score, kills, deaths) VALUES
 (1,1,'red',25,15,3),
 (1,3,'blue',10,5,10),
 (2,1,'blue',15,8,4),
 (2,2,'blue',12,6,5),
 (2,3,'red',8,4,7),
 (3,3,'red',30,18,2),
 (3,4,'blue',5,2,12),
 (4,1,'red',0,0,0);