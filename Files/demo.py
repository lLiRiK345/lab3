"""
demo.py — демонстрация запросов из requests.py на тестовых данных.
Запуск:  python seed.py && python demo.py
"""
from datetime import datetime

import requests as q
from database import engine
from sqlmodel import Session


def show(title: str, rows) -> None:
    print(f"\n=== {title} ===")
    rows = list(rows.items()) if isinstance(rows, dict) else list(rows)
    if not rows:
        print("(нет данных)")
    for row in rows:
        print("  ", tuple(row) if not isinstance(row, tuple) and hasattr(row, "_mapping") else row)


with Session(engine) as session:
    now = datetime(2026, 11, 3, 12, 0)

    show("Игрок shadow", [(p.id, p.username, p.email, p.status) for p in [q.get_player_by_username(session, "shadow")] if p])
    show("Активные сессии", q.get_active_sessions(session, now))
    show("Персонажи игрока №1", [(c.id, c.name, c.level, c.experience) for c in q.get_characters_by_player(session, 1)])
    show("Состав гильдии №1", q.get_guild_members(session, 1))
    show("Топ персонажей", q.get_top_characters(session))
    show("Инвентарь персонажа №1", q.get_inventory(session, 1))
    show("Стоимость инвентаря персонажа №1", q.get_total_inventory_value(session, 1))
    show("Надетые предметы персонажа №1", q.get_equipped_items(session, 1))
    show("Завершённые матчи", q.get_match_results(session))
    show("Статистика матча №2", q.get_match_statistics(session, 2))
    show("История матчей игрока №1", q.get_player_match_history(session, 1))
    show("Загрузка серверов", q.get_server_load(session))
    show("Достижения персонажа №1", q.get_character_achievements(session, 1))
    show("Топ убийц", q.get_top_killers(session))
    show("K/D по персонажам", q.get_kd_ratio(session))

    try:
        new_char = q.create_character(session, player_id=3, name="RavenStorm")
        show("Создан персонаж", [(new_char.id, new_char.name, new_char.level)])
    except ValueError as e:
        show("Создание персонажа", [("пропущено", str(e))])