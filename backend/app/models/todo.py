from datetime import datetime
from typing import Optional
from uuid import uuid4

from sqlmodel import Field, Relationship, SQLModel


class Todo(SQLModel, table=True):
    __tablename__ = "todos"

    id: str = Field(default_factory=lambda: str(uuid4()), primary_key=True, index=True)
    owner_id: str = Field(foreign_key="users.id", index=True)
    title: str
    description: Optional[str] = None
    is_completed: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

    owner: "User" = Relationship(back_populates="todos")


from .user import User  # noqa: E402
