from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.models import Todo, User
from app.schemas import TodoCreate, TodoRead, TodoUpdate

router = APIRouter(prefix="/todos", tags=["todos"])


def _get_user_todo(session: Session, todo_id: str, user_id: str) -> Todo:
    todo = session.query(Todo).filter(Todo.id == todo_id, Todo.owner_id == user_id).first()
    if not todo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found")
    return todo


@router.get("", response_model=List[TodoRead])
def list_todos(
    session: Session = Depends(deps.get_session),
    current_user: User = Depends(deps.get_current_user),
) -> List[Todo]:
    return (
        session.query(Todo)
        .filter(Todo.owner_id == current_user.id)
        .order_by(Todo.created_at.desc())
        .all()
    )


@router.post("", response_model=TodoRead, status_code=status.HTTP_201_CREATED)
def create_todo(
    payload: TodoCreate,
    session: Session = Depends(deps.get_session),
    current_user: User = Depends(deps.get_current_user),
) -> Todo:
    todo = Todo(**payload.model_dump(), owner_id=current_user.id)
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return todo


@router.patch("/{todo_id}", response_model=TodoRead)
def update_todo(
    todo_id: str,
    payload: TodoUpdate,
    session: Session = Depends(deps.get_session),
    current_user: User = Depends(deps.get_current_user),
) -> Todo:
    todo = _get_user_todo(session, todo_id, current_user.id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(todo, field, value)
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return todo


@router.delete("/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_todo(
    todo_id: str,
    session: Session = Depends(deps.get_session),
    current_user: User = Depends(deps.get_current_user),
) -> None:
    todo = _get_user_todo(session, todo_id, current_user.id)
    session.delete(todo)
    session.commit()
