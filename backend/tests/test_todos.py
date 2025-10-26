def create_user_and_token(client, email="todo@example.com"):
    payload = {"email": email, "full_name": "Todo User", "password": "password123"}
    client.post("/auth/register", json=payload)
    token_resp = client.post(
        "/auth/token",
        data={"username": payload["email"], "password": payload["password"]},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    return token_resp.json()["access_token"]


def test_todo_crud_flow(client):
    token = create_user_and_token(client)
    headers = {"Authorization": f"Bearer {token}"}

    create_resp = client.post(
        "/todos",
        json={"title": "First", "description": "Example"},
        headers=headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    todo = create_resp.json()

    list_resp = client.get("/todos", headers=headers)
    assert list_resp.status_code == 200
    assert len(list_resp.json()) == 1

    patch_resp = client.patch(
        f"/todos/{todo['id']}",
        json={"is_completed": True},
        headers=headers,
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["is_completed"] is True

    delete_resp = client.delete(f"/todos/{todo['id']}", headers=headers)
    assert delete_resp.status_code == 204

    empty_resp = client.get("/todos", headers=headers)
    assert empty_resp.status_code == 200
    assert empty_resp.json() == []
