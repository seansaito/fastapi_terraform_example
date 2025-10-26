from functools import lru_cache
from typing import List, Union

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Azure Todo API"
    app_env: str = Field("local", alias="APP_ENV")
    log_level: str = Field("INFO", alias="LOG_LEVEL")
    database_url: str = Field(..., alias="DATABASE_URL")
    jwt_secret: str = Field(..., alias="JWT_SECRET")
    access_token_expire_minutes: int = Field(60, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    cors_origins: Union[List[str], str] = Field(default="http://localhost:5173", alias="CORS_ORIGINS")

    class Config:
        env_file = ".env"
        case_sensitive = False

    @field_validator("cors_origins", mode="after")
    @classmethod
    def split_origins(cls, value: Union[List[str], str]) -> List[str]:
        if isinstance(value, str):
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value


@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[arg-type]


def reset_settings_cache() -> None:
    get_settings.cache_clear()
