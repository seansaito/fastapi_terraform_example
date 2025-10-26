"""Seed script to create a demo user and todos."""
from app.db.session import session_scope
from app.models import Todo, User
from app.services.security import get_password_hash


def run() -> None:
    with session_scope() as session:
        if session.query(User).count() == 0:
            user = User(
                email="demo@example.com",
                full_name="Demo User",
                password_hash=get_password_hash("demo1234"),
            )
            session.add(user)
            session.flush()
            session.add_all(
                [
                    Todo(owner_id=user.id, title="Welcome", description="This todo was seeded"),
                    Todo(owner_id=user.id, title="Try the UI", is_completed=False),
                ]
            )
            print("Seeded demo user demo@example.com / demo1234")
        else:
            print("Users already exist; skipping seed")


if __name__ == "__main__":
    run()
