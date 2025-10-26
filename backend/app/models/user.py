from datetime import datetime
from typing import List
from uuid import uuid4

from sqlmodel import Field, Relationship, SQLModel


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: str = Field(default_factory=lambda: str(uuid4()), primary_key=True, index=True)
    email: str = Field(index=True, unique=True)
    full_name: str
    password_hash: str
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

    todos: List["Todo"] = Relationship(back_populates="owner")


from .todo import Todo  # noqa: E402  (circular import guard)
