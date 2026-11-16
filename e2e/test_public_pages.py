"""Pages anyone opens: home, a taxon's catalog page and its other views, search, references, static pages, llms.txt,
and what a missing page answers (e2e/README.md)."""
import re

from conftest import TAXON_ID, get


def ok(path, **kw):
    r = get(path, **kw)
    assert r.status_code == 200, (path, r.status_code, r.text[:300])
    return r


def test_home_page_shows_the_catalog_and_the_version():
    body = ok("/").text
    assert "AntCat" in body
    assert re.search(r"Version \d+\.\d+\.\d+", body), "no version in the footer"


def test_a_taxon_page_and_its_views():
    body = ok(f"/catalog/{TAXON_ID}").text
    assert "<title>" in body and "AntCat" in body
    for view in ("history", "bolton", "what_links_here"):
        ok(f"/catalog/{TAXON_ID}/{view}")


def test_search_finds_a_genus():
    r = get("/catalog/search?qq=Camponotus", allow_redirects=True)
    assert r.status_code == 200, r.status_code
    assert "Camponotus" in r.text


def test_references_latest_additions_and_search():
    body = ok("/references/latest_additions").text
    assert "Latest Additions" in body and "<table" in body
    assert ok("/references/search?reference_q=Bolton").status_code == 200


def test_static_pages():
    for page in ("/about", "/contribute"):
        ok(page)


def test_llms_txt_is_plain_text():
    r = ok("/llms.txt")
    assert r.headers.get("Content-Type", "").startswith("text/plain"), r.headers.get("Content-Type")
    assert "/v1" in r.text


def test_a_missing_page_is_404():
    assert get("/no_such_page_here").status_code == 404
    assert get("/catalog/999999999").status_code == 404


def test_pages_carry_a_content_security_policy():
    r = ok("/")
    assert "Content-Security-Policy" in r.headers or "Content-Security-Policy-Report-Only" in r.headers, dict(r.headers)
