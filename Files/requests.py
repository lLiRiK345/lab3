"""
requests.py — запросы к базе данных игры (SQLModel) для основных процессов.

Процессы: аккаунты, персонажи и гильдии, экономика, матчи и статистика,
достижения. Каждая функция принимает сессию SQLModel и возвращает результат;
изменяющая функция одна — create_character.
"""
from datetime import datetime
from typing import Optional

from sqlalchemy import desc, func
from sqlmodel import Session, col, select

from models import (
    Achievement, Character, GameServer, InventoryItem, Item, ItemType,
    Match, MatchPlayer, Player, Session as PlayerSession,
)


# ====================================================================
# 1. Аккаунты и безопасность
# ====================================================================
def get_player_by_username(session: Session, username: str) -> Optional[Player]:
    """Найти игрока по имени."""
    return session.exec(select(Player).where(Player.username == username)).first()


def get_active_sessions(session: Session, now: Optional[datetime] = None):
    """Активные сессии (токен ещё не истёк) с именем игрока."""
    now = now or datetime.now()
    stmt = (
        select(PlayerSession.token, Player.username, PlayerSession.ip_address,
               PlayerSession.created_at, PlayerSession.expires_at)
        .select_from(PlayerSession)
        .join(Player, Player.id == PlayerSession.player_id)
        .where(PlayerSession.expires_at > now)
        .order_by(PlayerSession.created_at)
    )
    return session.exec(stmt).all()


# ====================================================================
# 2. Персонажи и гильдии
# ====================================================================
def get_characters_by_player(session: Session, player_id: int):
    """Все персонажи игрока."""
    stmt = (
        select(Character)
        .where(Character.player_id == player_id)
        .order_by(Character.level.desc())
    )
    return session.exec(stmt).all()


def get_guild_members(session: Session, guild_id: int):
    """Состав гильдии: персонажи с уровнем и опытом."""
    stmt = (
        select(Character.name, Character.level, Character.experience)
        .select_from(Character)
        .where(Character.guild_id == guild_id)
        .order_by(desc(Character.level))
    )
    return session.exec(stmt).all()


def get_top_characters(session: Session, limit: int = 10):
    """Топ персонажей по уровню и опыту (лидерборд)."""
    stmt = (
        select(Character.name, Player.username, Character.level, Character.experience)
        .select_from(Character)
        .join(Player, Player.id == Character.player_id)
        .order_by(desc(Character.level), desc(Character.experience))
        .limit(limit)
    )
    return session.exec(stmt).all()


def create_character(session: Session, player_id: int, name: str) -> Character:
    """Создаёт нового персонажа первого уровня для игрока."""
    existing = session.exec(select(Character).where(Character.name == name)).first()
    if existing is not None:
        raise ValueError(f"Имя персонажа '{name}' уже занято")
    character = Character(
        player_id=player_id,
        name=name,
        level=1,
        experience=0,
        health=100,
        mana=100,
        position_x=0.0,
        position_y=0.0,
        position_z=0.0,
        created_at=datetime.now(),
    )
    session.add(character)
    session.commit()
    session.refresh(character)
    return character


# ====================================================================
# 3. Экономика и предметы
# ====================================================================
def get_inventory(session: Session, character_id: int):
    """Инвентарь персонажа: предмет, количество, слот, надет ли."""
    stmt = (
        select(Item.name, ItemType.name.label("type"), InventoryItem.quantity,
               InventoryItem.slot, InventoryItem.equipped, Item.price)
        .select_from(InventoryItem)
        .join(Item, Item.id == InventoryItem.item_id)
        .join(ItemType, ItemType.id == Item.type_id)
        .where(InventoryItem.character_id == character_id)
        .order_by(InventoryItem.slot)
    )
    return session.exec(stmt).all()


def get_total_inventory_value(session: Session, character_id: int):
    """Суммарная стоимость инвентаря персонажа."""
    total = func.sum(Item.price * InventoryItem.quantity)
    stmt = (
        select(total.label("total_value"))
        .select_from(InventoryItem)
        .join(Item, Item.id == InventoryItem.item_id)
        .where(InventoryItem.character_id == character_id)
    )
    return session.exec(stmt).first()


def get_equipped_items(session: Session, character_id: int):
    """Надетые предметы персонажа."""
    stmt = (
        select(Item.name, ItemType.name.label("type"), Item.base_stats)
        .select_from(InventoryItem)
        .join(Item, Item.id == InventoryItem.item_id)
        .join(ItemType, ItemType.id == Item.type_id)
        .where(InventoryItem.character_id == character_id, InventoryItem.equipped == True)  # noqa: E712
    )
    return session.exec(stmt).all()


# ====================================================================
# 4. Матчи и статистика
# ====================================================================
def get_match_results(session: Session):
    """Все завершённые матчи с сервером и победителем."""
    stmt = (
        select(Match.id, GameServer.region, Match.game_mode, Match.map_name,
               Match.start_time, Match.end_time, Match.winner_team)
        .select_from(Match)
        .join(GameServer, GameServer.id == Match.server_id)
        .where(col(Match.end_time).is_not(None))
        .order_by(Match.start_time)
    )
    return session.exec(stmt).all()


def get_match_statistics(session: Session, match_id: int):
    """Статистика всех игроков в матче (сортировка по очкам)."""
    stmt = (
        select(Character.name, MatchPlayer.team, MatchPlayer.score,
               MatchPlayer.kills, MatchPlayer.deaths)
        .select_from(MatchPlayer)
        .join(Character, Character.id == MatchPlayer.character_id)
        .where(MatchPlayer.match_id == match_id)
        .order_by(desc(MatchPlayer.score))
    )
    return session.exec(stmt).all()


def get_player_match_history(session: Session, player_id: int):
    """История матчей игрока (по всем его персонажам)."""
    stmt = (
        select(Match.id, Match.game_mode, Match.start_time,
               Character.name, MatchPlayer.score, MatchPlayer.kills, MatchPlayer.deaths)
        .select_from(MatchPlayer)
        .join(Character, Character.id == MatchPlayer.character_id)
        .join(Match, Match.id == MatchPlayer.match_id)
        .where(Character.player_id == player_id)
        .order_by(Match.start_time)
    )
    return session.exec(stmt).all()


def get_server_load(session: Session):
    """Загрузка серверов: текущее число игроков и процент заполнения."""
    pct = (GameServer.current_players * 100.0 / GameServer.max_players).label("fill_pct")
    stmt = (
        select(GameServer.region, GameServer.ip_address, GameServer.status,
               GameServer.current_players, GameServer.max_players, pct)
        .order_by(desc(pct))
    )
    return session.exec(stmt).all()


# ====================================================================
# 5. Достижения и аналитика
# ====================================================================
def get_character_achievements(session: Session, character_id: int):
    """Достижения персонажа."""
    stmt = (
        select(Achievement.name, Achievement.description, Achievement.unlocked_at)
        .where(Achievement.character_id == character_id)
        .order_by(Achievement.unlocked_at)
    )
    return session.exec(stmt).all()


def get_top_killers(session: Session, limit: int = 10):
    """Топ персонажей по числу убийств во всех матчах."""
    total_kills = func.sum(MatchPlayer.kills)
    stmt = (
        select(Character.name, Player.username, total_kills.label("total_kills"))
        .select_from(MatchPlayer)
        .join(Character, Character.id == MatchPlayer.character_id)
        .join(Player, Player.id == Character.player_id)
        .group_by(Character.id, Character.name, Player.username)
        .order_by(desc(total_kills))
        .limit(limit)
    )
    return session.exec(stmt).all()


def get_kd_ratio(session: Session):
    """Соотношение убийств/смертей по персонажам (K/D)."""
    kills = func.sum(MatchPlayer.kills)
    deaths = func.sum(MatchPlayer.deaths)
    ratio = (kills * 1.0 / func.nullif(deaths, 0)).label("kd")
    stmt = (
        select(Character.name, kills.label("kills"), deaths.label("deaths"), ratio)
        .select_from(MatchPlayer)
        .join(Character, Character.id == MatchPlayer.character_id)
        .group_by(Character.id, Character.name)
        .order_by(desc(ratio))
    )
    return session.exec(stmt).all()