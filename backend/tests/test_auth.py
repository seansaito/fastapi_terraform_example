def test_register_and_login_flow(client):
    register_payload = {
        "email": "user@example.com",
        "full_name": "Test User",
        "password": "password123",
    }

    resp = client.post("/auth/register", json=register_payload)
    assert resp.status_code == 201, resp.text
    user = resp.json()
    assert user["email"] == register_payload["email"]

    token_resp = client.post(
        "/auth/token",
        data={"username": register_payload["email"], "password": register_payload["password"]},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert token_resp.status_code == 200
    token = token_resp.json()["access_token"]

    me_resp = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_resp.status_code == 200
    assert me_resp.json()["email"] == register_payload["email"]


def test_login_fails_for_bad_password(client):
    payload = {
        "email": "user2@example.com",
        "full_name": "Bad Password",
        "password": "correct",
    }

    client.post("/auth/register", json=payload)

    resp = client.post(
        "/auth/token",
        data={"username": payload["email"], "password": "wrong"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert resp.status_code == 401
