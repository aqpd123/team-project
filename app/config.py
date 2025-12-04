import os
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")


class Config:
    DEBUG: bool = False
    TESTING: bool = False
    SECRET_KEY: str = os.getenv("SECRET_KEY", "change-me")
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///app.db")
    LUNAR_API_KEY: str = os.getenv(
        "LUNAR_API_KEY",
        "72033766be7ee41338af559f9e99138d77c3f29be234bd231e5b88414aff05ea",
    )
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    MODEL_DIR: str = os.getenv("MODEL_DIR", str(BASE_DIR / "source"))


class DevelopmentConfig(Config):
    DEBUG = True


class TestingConfig(Config):
    TESTING = True


class ProductionConfig(Config):
    DEBUG = False
    TESTING = False


_ENV_MAP = {
    "development": DevelopmentConfig,
    "dev": DevelopmentConfig,
    "testing": TestingConfig,
    "test": TestingConfig,
    "production": ProductionConfig,
    "prod": ProductionConfig,
}


def get_config(env_name: str | None = None) -> type[Config]:
    name = (env_name or os.getenv("APP_ENV") or os.getenv("FLASK_ENV") or "development").lower()
    return _ENV_MAP.get(name, Config)

