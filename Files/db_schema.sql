-- Лабораторная работа №2. Многопользовательская игра (клиент-серверная архитектура)
-- СУБД: SQLite (схема совместима с PostgreSQL). Перед работой: PRAGMA foreign_keys = ON;

CREATE TABLE player (
    id INTEGER PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    last_login DATETIME,
    status VARCHAR(20) NOT NULL DEFAULT 'активен',
    CHECK (status IN ('активен','заблокирован','удалён'))
);

CREATE TABLE session (
    id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    token VARCHAR(128) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    created_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (player_id) REFERENCES player (id) ON DELETE CASCADE
);

CREATE TABLE guild (
    id INTEGER PRIMARY KEY,
    owner_id INTEGER NOT NULL,
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(500),
    created_at DATETIME NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES player (id) ON DELETE RESTRICT
);

CREATE TABLE character (
    id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    guild_id INTEGER,
    name VARCHAR(80) NOT NULL UNIQUE,
    level INTEGER NOT NULL DEFAULT 1,
    experience INTEGER NOT NULL DEFAULT 0,
    health INTEGER NOT NULL DEFAULT 100,
    mana INTEGER NOT NULL DEFAULT 100,
    position_x REAL NOT NULL DEFAULT 0,
    position_y REAL NOT NULL DEFAULT 0,
    position_z REAL NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    CHECK (level > 0),
    CHECK (experience >= 0),
    CHECK (health >= 0),
    CHECK (mana >= 0),
    FOREIGN KEY (player_id) REFERENCES player (id) ON DELETE CASCADE,
    FOREIGN KEY (guild_id) REFERENCES guild (id) ON DELETE SET NULL
);

CREATE TABLE item_type (
    id INTEGER PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    category VARCHAR(40) NOT NULL
);

CREATE TABLE item (
    id INTEGER PRIMARY KEY,
    type_id INTEGER NOT NULL,
    name VARCHAR(120) NOT NULL,
    rarity VARCHAR(20) NOT NULL,
    base_stats VARCHAR(500),
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    CHECK (price >= 0),
    FOREIGN KEY (type_id) REFERENCES item_type (id) ON DELETE RESTRICT
);

CREATE TABLE inventory_item (
    character_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    slot INTEGER NOT NULL DEFAULT 0,
    equipped BOOLEAN NOT NULL DEFAULT 0,
    CHECK (quantity > 0),
    CHECK (slot >= 0),
    PRIMARY KEY (character_id, item_id),
    FOREIGN KEY (character_id) REFERENCES character (id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item (id) ON DELETE RESTRICT
);

CREATE TABLE achievement (
    id INTEGER PRIMARY KEY,
    character_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    unlocked_at DATETIME NOT NULL,
    FOREIGN KEY (character_id) REFERENCES character (id) ON DELETE CASCADE
);

CREATE TABLE game_server (
    id INTEGER PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL UNIQUE,
    port INTEGER NOT NULL,
    region VARCHAR(40) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'online',
    max_players INTEGER NOT NULL DEFAULT 100,
    current_players INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE match (
    id INTEGER PRIMARY KEY,
    server_id INTEGER NOT NULL,
    game_mode VARCHAR(40) NOT NULL,
    map_name VARCHAR(80) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    winner_team VARCHAR(20),
    CHECK (end_time IS NULL OR end_time >= start_time),
    FOREIGN KEY (server_id) REFERENCES game_server (id) ON DELETE RESTRICT
);

CREATE TABLE match_player (
    match_id INTEGER NOT NULL,
    character_id INTEGER NOT NULL,
    team VARCHAR(20) NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    kills INTEGER NOT NULL DEFAULT 0,
    deaths INTEGER NOT NULL DEFAULT 0,
    CHECK (kills >= 0),
    CHECK (deaths >= 0),
    CHECK (score >= 0),
    PRIMARY KEY (match_id, character_id),
    FOREIGN KEY (match_id) REFERENCES match (id) ON DELETE CASCADE,
    FOREIGN KEY (character_id) REFERENCES character (id) ON DELETE CASCADE
);

CREATE INDEX ix_character_player ON character (player_id);
CREATE INDEX ix_match_server ON match (server_id);
CREATE INDEX ix_achievement_character ON achievement (character_id);