"""
models.py — модели SQLModel для базы данных многопользовательской игры.

Модели соответствуют таблицам, спроектированным в лабораторной работе №2
(см. db_schema.sql): 11 таблиц, внешние ключи, ограничения CHECK и индексы.
Имена таблиц заданы явно (__tablename__), чтобы они совпадали со скриптом db_schema.sql.

Примечание: поля типа datetime объявлены как NaiveDatetime, т.к. SQLite не хранит
таймзону, а тестовые данные (seed_data.sql) заданы без неё.
"""
from datetime import date, datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import NaiveDatetime
from sqlalchemy import CheckConstraint, Index, UniqueConstraint
from sqlmodel import Field, Relationship, SQLModel


# ====================================================================
# 1. Аккаунты и безопасность
# ====================================================================
class Player(SQLModel, table=True):
    """Учётная запись игрока — центральная сущность."""
    __tablename__ = "player"
    __table_args__ = (
        CheckConstraint("status IN ('активен','заблокирован','удалён')", name="ck_player_status"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(max_length=64, unique=True)
    email: str = Field(max_length=120, unique=True)
    password_hash: str = Field(max_length=255)
    created_at: NaiveDatetime
    last_login: Optional[NaiveDatetime] = None
    status: str = Field(default="активен", max_length=20)

    sessions: List["Session"] = Relationship(back_populates="player")
    characters: List["Character"] = Relationship(back_populates="player")
    guilds: List["Guild"] = Relationship(back_populates="owner")


class Session(SQLModel, table=True):
    """Сессия входа (токен авторизации)."""
    __tablename__ = "session"

    id: Optional[int] = Field(default=None, primary_key=True)
    player_id: int = Field(foreign_key="player.id")
    token: str = Field(max_length=128, unique=True)
    ip_address: Optional[str] = Field(default=None, max_length=45)
    created_at: NaiveDatetime
    expires_at: NaiveDatetime

    player: Optional[Player] = Relationship(back_populates="sessions")


# ====================================================================
# 2. Гильдии и персонажи
# ====================================================================
class Guild(SQLModel, table=True):
    """Гильдия игроков."""
    __tablename__ = "guild"

    id: Optional[int] = Field(default=None, primary_key=True)
    owner_id: int = Field(foreign_key="player.id")
    name: str = Field(max_length=80, unique=True)
    description: Optional[str] = Field(default=None, max_length=500)
    created_at: NaiveDatetime

    owner: Optional[Player] = Relationship(back_populates="guilds")
    members: List["Character"] = Relationship(back_populates="guild")


class Character(SQLModel, table=True):
    """Игровой персонаж (принадлежит игроку, может состоять в гильдии)."""
    __tablename__ = "character"
    __table_args__ = (
        CheckConstraint("level > 0", name="ck_character_level"),
        CheckConstraint("experience >= 0", name="ck_character_exp"),
        CheckConstraint("health >= 0", name="ck_character_health"),
        CheckConstraint("mana >= 0", name="ck_character_mana"),
        Index("ix_character_player", "player_id"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    player_id: int = Field(foreign_key="player.id")
    guild_id: Optional[int] = Field(default=None, foreign_key="guild.id")
    name: str = Field(max_length=80, unique=True)
    level: int = Field(default=1)
    experience: int = Field(default=0)
    health: int = Field(default=100)
    mana: int = Field(default=100)
    position_x: float = Field(default=0.0)
    position_y: float = Field(default=0.0)
    position_z: float = Field(default=0.0)
    created_at: NaiveDatetime

    player: Optional[Player] = Relationship(back_populates="characters")
    guild: Optional[Guild] = Relationship(back_populates="members")
    inventory: List["InventoryItem"] = Relationship(back_populates="character")
    achievements: List["Achievement"] = Relationship(back_populates="character")
    matches: List["MatchPlayer"] = Relationship(back_populates="character")


# ====================================================================
# 3. Экономика и предметы
# ====================================================================
class ItemType(SQLModel, table=True):
    """Тип предмета (справочник)."""
    __tablename__ = "item_type"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=80, unique=True)
    category: str = Field(max_length=40)


class Item(SQLModel, table=True):
    """Предмет (характеристики и цена)."""
    __tablename__ = "item"
    __table_args__ = (
        CheckConstraint("price >= 0", name="ck_item_price"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    type_id: int = Field(foreign_key="item_type.id")
    name: str = Field(max_length=120)
    rarity: str = Field(max_length=20)
    base_stats: Optional[str] = Field(default=None, max_length=500)
    price: Decimal = Field(default=Decimal("0"), max_digits=12, decimal_places=2)


class InventoryItem(SQLModel, table=True):
    """Предмет в инвентаре персонажа (связь M:N: Character ↔ Item)."""
    __tablename__ = "inventory_item"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="ck_inventory_qty"),
        CheckConstraint("slot >= 0", name="ck_inventory_slot"),
    )

    character_id: int = Field(foreign_key="character.id", primary_key=True)
    item_id: int = Field(foreign_key="item.id", primary_key=True)
    quantity: int = Field(default=1)
    slot: int = Field(default=0)
    equipped: bool = Field(default=False)

    character: Optional[Character] = Relationship(back_populates="inventory")


# ====================================================================
# 4. Матчи и серверная инфраструктура
# ====================================================================
class GameServer(SQLModel, table=True):
    """Игровой сервер."""
    __tablename__ = "game_server"

    id: Optional[int] = Field(default=None, primary_key=True)
    ip_address: str = Field(max_length=45, unique=True)
    port: int
    region: str = Field(max_length=40)
    status: str = Field(default="online", max_length=20)
    max_players: int = Field(default=100)
    current_players: int = Field(default=0)

    matches: List["Match"] = Relationship(back_populates="server")


class Match(SQLModel, table=True):
    """Игровая сессия (матч) на конкретном сервере."""
    __tablename__ = "match"
    __table_args__ = (
        CheckConstraint("end_time IS NULL OR end_time >= start_time", name="ck_match_period"),
        Index("ix_match_server", "server_id"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    server_id: int = Field(foreign_key="game_server.id")
    game_mode: str = Field(max_length=40)
    map_name: str = Field(max_length=80)
    start_time: NaiveDatetime
    end_time: Optional[NaiveDatetime] = None
    winner_team: Optional[str] = Field(default=None, max_length=20)

    server: Optional[GameServer] = Relationship(back_populates="matches")
    players: List["MatchPlayer"] = Relationship(back_populates="match")


class MatchPlayer(SQLModel, table=True):
    """Статистика персонажа в матче (связь M:N: Match ↔ Character)."""
    __tablename__ = "match_player"
    __table_args__ = (
        CheckConstraint("kills >= 0", name="ck_mp_kills"),
        CheckConstraint("deaths >= 0", name="ck_mp_deaths"),
        CheckConstraint("score >= 0", name="ck_mp_score"),
    )

    match_id: int = Field(foreign_key="match.id", primary_key=True)
    character_id: int = Field(foreign_key="character.id", primary_key=True)
    team: str = Field(max_length=20)
    score: int = Field(default=0)
    kills: int = Field(default=0)
    deaths: int = Field(default=0)

    match: Optional[Match] = Relationship(back_populates="players")
    character: Optional[Character] = Relationship(back_populates="matches")


# ====================================================================
# 5. Прогресс
# ====================================================================
class Achievement(SQLModel, table=True):
    """Достижение персонажа."""
    __tablename__ = "achievement"
    __table_args__ = (
        Index("ix_achievement_character", "character_id"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    character_id: int = Field(foreign_key="character.id")
    name: str = Field(max_length=100)
    description: Optional[str] = Field(default=None, max_length=500)
    unlocked_at: NaiveDatetime

    character: Optional[Character] = Relationship(back_populates="achievements")