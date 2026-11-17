"""The /v1 API (e2e/README.md): the front door answers without a key; a single record works without one; a list of all
records needs one once keys are on (401 with the header that names it; skipped where keys are off); with the test key a
taxon and a list answer."""
import pytest

from conftest import API_KEY, TAXON_ID, get


def test_front_door_answers_without_a_key():
    r = get("/v1")
    assert r.status_code == 200, r.status_code
    assert r.headers.get("Content-Type", "").startswith("application/json")
    assert "api_keys" in r.json() or "status" in r.json(), r.text[:300]


def test_a_single_record_works_without_a_key():
    """Single records need no key (the uptime check reads /v1/taxa/429011 without one)."""
    r = get(f"/v1/taxa/{TAXON_ID}")
    assert r.status_code == 200, (r.status_code, r.text[:300])
    (_kind, taxon), = r.json().items()
    assert taxon["id"] == TAXON_ID, taxon


def test_a_list_without_a_key_is_401_and_names_the_header():
    """Lists of all records need a key, once keys are on (the front door says api_keys.status "live"; staging may
    run with keys off, "coming")."""
    status = get("/v1").json().get("api_keys", {}).get("status")
    if status != "live":
        pytest.skip("API keys are not on here (api_keys.status " + repr(status) + ")")
    r = get("/v1/taxa")
    assert r.status_code == 401, r.status_code
    assert "X-API-Key" in r.headers.get("WWW-Authenticate", ""), dict(r.headers)
    assert r.json().get("error") == "API key needed", r.text[:300]
    bad = get("/v1/taxa", headers={"X-API-Key": "not-a-key"})
    assert bad.status_code == 401 and bad.json().get("error") == "API key not valid", bad.text[:300]


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
