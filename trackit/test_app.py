from app import app

def test_health():
    r = app.test_client().get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"

def test_shipment_static():
    r = app.test_client().get("/api/shipments/BH-1001")
    assert r.status_code == 200
    assert r.get_json()["id"] == "BH-1001"
