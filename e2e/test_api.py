"""The /v1 API (e2e/README.md): the front door answers without a key; data needs a key (401 with the header that names
it); with the test key a taxon answers with its id."""
import pytest

from conftest import API_KEY, TAXON_ID, get


def test_front_door_answers_without_a_key():
    r = get("/v1")
    assert r.status_code == 200, r.status_code
    assert r.headers.get("Content-Type", "").startswith("application/json")
    assert "api_keys" in r.json() or "status" in r.json(), r.text[:300]


def test_data_without_a_key_is_401_and_names_the_header():
    r = get(f"/v1/taxa/{TAXON_ID}")
    assert r.status_code == 401, r.status_code
    assert "X-API-Key" in r.headers.get("WWW-Authenticate", ""), dict(r.headers)


@pytest.mark.skipif(not API_KEY, reason="ANTCAT_TEST_API_KEY not set")
def test_a_taxon_with_the_test_key():
    r = get(f"/v1/taxa/{TAXON_ID}", headers={"X-API-Key": API_KEY})
    assert r.status_code == 200, (r.status_code, r.text[:300])
    (_kind, taxon), = r.json().items()
    assert taxon["id"] == TAXON_ID, taxon
    assert taxon["name_cache"], taxon


@pytest.mark.skipif(not API_KEY, reason="ANTCAT_TEST_API_KEY not set")
def test_a_list_with_the_test_key():
    r = get("/v1/taxa?starts_at=1", headers={"X-API-Key": API_KEY})
    assert r.status_code == 200, (r.status_code, r.text[:300])
    assert isinstance(r.json(), list) and r.json(), r.text[:300]
