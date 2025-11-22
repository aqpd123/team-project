from __future__ import annotations

import os
from contextlib import contextmanager
from typing import Generator, Optional

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import sessionmaker, Session

from . import models


class Database:
    def __init__(self) -> None:
        self._engine: Optional[Engine] = None
        self._SessionLocal: Optional[sessionmaker] = None
        self._database_url: Optional[str] = None

    def init_app(self, database_url: str | None = None) -> None:
        url = database_url or os.getenv("DATABASE_URL") or "sqlite:///app.db"
        if self._engine is not None and self._database_url == url:
            return

        self._engine = create_engine(url, pool_pre_ping=True, future=True)
        self._SessionLocal = sessionmaker(bind=self._engine, autoflush=False, autocommit=False, future=True)
        models.create_all(self._engine)
        self._database_url = url

    @contextmanager
    def session(self) -> Generator[Session, None, None]:
        if self._SessionLocal is None:
            self.init_app()
        assert self._SessionLocal is not None
        session: Session = self._SessionLocal()
        try:
            yield session
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()

    @property
    def engine(self) -> Engine:
        if self._engine is None:
            self.init_app()
        assert self._engine is not None
        return self._engine


db = Database()
