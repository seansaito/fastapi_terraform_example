import os
from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlmodel import SQLModel

from app.api import deps
from app.core.config import reset_settings_cache
from app.db.session import get_db
from app.main import app

TEST_DB_URL = "sqlite:///./test.db"


@pytest.fixture(scope="session", autouse=True)
def _setup_env() -> Generator[None, None, None]:
    os.environ.setdefault("DATABASE_URL", TEST_DB_URL)
    os.environ.setdefault("JWT_SECRET", "test-secret")
    os.environ.setdefault("ACCESS_TOKEN_EXPIRE_MINUTES", "60")
    os.environ.setdefault("CORS_ORIGINS", "http://testserver")
    reset_settings_cache()
    yield
    reset_settings_cache()


@pytest.fixture(scope="session")
def engine() -> Generator:
    engine = create_engine(TEST_DB_URL, connect_args={"check_same_thread": False})
    SQLModel.metadata.create_all(engine)
    yield engine
    SQLModel.metadata.drop_all(engine)


@pytest.fixture()
def db_session(engine) -> Generator[Session, None, None]:
    TestingSessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture()
def client(db_session: Session) -> Generator[TestClient, None, None]:
    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.pop(get_db, None)
