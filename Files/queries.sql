-- SQL-эквиваленты запросов из requests.py (для проверки результатов)

-- Q01 get_player_by_username
SELECT * FROM player WHERE username = 'shadow';

-- Q02 get_active_sessions (на 2026-11-03 12:00)
SELECT s.token, p.username, s.ip_address, s.created_at, s.expires_at
FROM session s JOIN player p ON p.id = s.player_id
WHERE s.expires_at > '2026-11-03 12:00:00' ORDER BY s.created_at;

-- Q03 get_characters_by_player (игрок 1)
SELECT * FROM character WHERE player_id = 1 ORDER BY level DESC;

-- Q04 get_guild_members (гильдия 1)
SELECT name, level, experience FROM character WHERE guild_id = 1 ORDER BY level DESC;

-- Q05 get_top_characters (топ-10)
SELECT c.name, p.username, c.level, c.experience
FROM character c JOIN player p ON p.id = c.player_id
ORDER BY c.level DESC, c.experience DESC LIMIT 10;

-- Q06 get_inventory (персонаж 1)
SELECT i.name, it.name AS type, inv.quantity, inv.slot, inv.equipped, i.price
FROM inventory_item inv
JOIN item i ON i.id = inv.item_id
JOIN item_type it ON it.id = i.type_id
WHERE inv.character_id = 1 ORDER BY inv.slot;

-- Q07 get_total_inventory_value (персонаж 1)
SELECT SUM(i.price * inv.quantity) AS total_value
FROM inventory_item inv JOIN item i ON i.id = inv.item_id
WHERE inv.character_id = 1;

-- Q08 get_equipped_items (персонаж 1)
SELECT i.name, it.name AS type, i.base_stats
FROM inventory_item inv
JOIN item i ON i.id = inv.item_id
JOIN item_type it ON it.id = i.type_id
WHERE inv.character_id = 1 AND inv.equipped = 1;

-- Q09 get_match_results
SELECT m.id, gs.region, m.game_mode, m.map_name, m.start_time, m.end_time, m.winner_team
FROM match m JOIN game_server gs ON gs.id = m.server_id
WHERE m.end_time IS NOT NULL ORDER BY m.start_time;

-- Q10 get_match_statistics (матч 2)
SELECT c.name, mp.team, mp.score, mp.kills, mp.deaths
FROM match_player mp JOIN character c ON c.id = mp.character_id
WHERE mp.match_id = 2 ORDER BY mp.score DESC;

-- Q11 get_player_match_history (игрок 1)
SELECT m.id, m.game_mode, m.start_time, c.name, mp.score, mp.kills, mp.deaths
FROM match_player mp
JOIN character c ON c.id = mp.character_id
JOIN match m ON m.id = mp.match_id
WHERE c.player_id = 1 ORDER BY m.start_time;

-- Q12 get_server_load
SELECT region, ip_address, status, current_players, max_players,
       current_players * 100.0 / max_players AS fill_pct
FROM game_server ORDER BY fill_pct DESC;

-- Q13 get_character_achievements (персонаж 1)
SELECT name, description, unlocked_at FROM achievement
WHERE character_id = 1 ORDER BY unlocked_at;

-- Q14 get_top_killers
SELECT c.name, p.username, SUM(mp.kills) AS total_kills
FROM match_player mp
JOIN character c ON c.id = mp.character_id
JOIN player p ON p.id = c.player_id
GROUP BY c.id, c.name, p.username
ORDER BY total_kills DESC LIMIT 10;

-- Q15 get_kd_ratio
SELECT c.name, SUM(mp.kills) AS kills, SUM(mp.deaths) AS deaths,
       SUM(mp.kills) * 1.0 / NULLIF(SUM(mp.deaths), 0) AS kd
FROM match_player mp JOIN character c ON c.id = mp.character_id
GROUP BY c.id, c.name ORDER BY kd DESC;