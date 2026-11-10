# Лабораторная работа №3. Использование SQLModel

Предметная область: многопользовательская игра (клиент-серверная архитектура).
СУБД: SQLite 3 (база хранится в файле `game.db`).

## Состав
| Файл | Назначение |
|---|---|
| `models.py` | Модели SQLModel (11 таблиц, соответствуют схеме из ЛР №2) |
| `requests.py` | Запросы к БД для основных процессов (15 функций) |
| `database.py` | Подключение к SQLite, включение внешних ключей, создание таблиц |
| `seed.py`, `seed_data.sql` | Создание базы и загрузка тестовых данных |
| `demo.py` | Пример вызова всех запросов с выводом результатов |
| `db_schema.sql` | Скрипт создания БД (из ЛР №2) |
| `queries.sql` | SQL-эквиваленты запросов из `requests.py` |
| `game.db`, `game_dump.sql` | Готовая база данных и её дамп (SQLite) |

## Запуск
```bash
python -m venv .venv
.venv\Scripts\activate          # Windows;  source .venv/bin/activate — Linux/macOS
pip install -r requirements.txt
python seed.py                  # создаёт game.db по моделям и заполняет данными
python demo.py                  # выполняет запросы и печатает результаты
```

Восстановить базу из дампа без Python:
```bash
sqlite3 game.db < game_dump.sql
```

## Пример использования
```python
from sqlmodel import Session
from database import engine
import requests as q

with Session(engine) as session:
    print(q.get_top_characters(session))
    print(q.get_match_statistics(session, 2))
    q.create_character(session, player_id=3, name="RavenStorm")
```

## Примечание о датах
В SQLModel 0.0.45+ поля `datetime` по умолчанию требуют timezone-aware значений.
Поскольку SQLite не хранит таймзону, в моделях `Player`, `Session`, `Guild`,
`Character`, `Match`, `Achievement` поля дат объявлены типом `NaiveDatetime`
(импортируется из `pydantic`).