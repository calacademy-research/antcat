"""Shared settings of the AntCat end-to-end tests (e2e/README.md): the site address and a session that sends the Host
header and the CA bundle when given. Every test is skipped when ANTCAT_URL is not set."""
import os
import urllib.parse

import pytest
import requests

BASE_URL = os.environ.get("ANTCAT_URL", "").rstrip("/")
HOST = os.environ.get("ANTCAT_HOST_HEADER", "")
CA = os.environ.get("ANTCAT_CA_BUNDLE", "")
API_KEY = os.environ.get("ANTCAT_TEST_API_KEY", "")
EDITOR_EMAIL = os.environ.get("ANTCAT_TEST_EDITOR_EMAIL", "")
EDITOR_PASSWORD = os.environ.get("ANTCAT_TEST_EDITOR_PASSWORD", "")
TIMEOUT = 60
TAXON_ID = 429011   # the taxon the deploy health check and the uptime check ask for (script/deploy)


def pytest_collection_modifyitems(config, items):
    if BASE_URL:
        return
    skip = pytest.mark.skip(reason="ANTCAT_URL not set")
    for item in items:
        item.add_marker(skip)


def session():
    s = requests.Session()
    s.headers["User-Agent"] = "AntCat e2e tests (github.com/calacademy-research/antcat)"
    s.headers["X-Forwarded-Proto"] = "https"
    if HOST:
        s.headers["Host"] = HOST
    if CA:
        s.verify = CA
    elif os.environ.get("ANTCAT_INSECURE_LOCAL") == "1" and BASE_URL.startswith("https://127.0.0.1:"):
        s.verify = False   # CI's SSH tunnel: the certificate is for the site's name, the address is the tunnel's
        requests.packages.urllib3.disable_warnings()
    return s


def follow(s, method, path, **kw):
    """A request that follows redirects only within the site under test: Rails writes absolute redirects with the Host
    header (www.antcat.org), so each Location is brought back to BASE_URL; a redirect to any other host fails the test
    instead of being fetched (the tests never reach antcat.org through a redirect)."""
    kw.setdefault("timeout", TIMEOUT)
    url = BASE_URL + path
    for _ in range(10):
        r = s.request(method, url, allow_redirects=False, **kw)
        if r.status_code not in (301, 302, 303, 307, 308):
            return r
        url = local(r.headers["Location"])
        if r.status_code in (301, 302, 303):
            method, kw = "GET", {k: v for k, v in kw.items() if k != "data"}
    raise AssertionError("more than 10 redirects from " + path)


def local(location):
    """A redirect's Location as an address of the site under test, or a failed test when it leaves the site."""
    parts = urllib.parse.urlsplit(location)
    if not parts.netloc:
        return BASE_URL + location
    ours = {urllib.parse.urlsplit(BASE_URL).netloc, HOST} - {""}
    assert parts.netloc in ours, "redirect leaves the site under test: " + location
    return BASE_URL + parts.path + ("?" + parts.query if parts.query else "")


def get(path, **kw):
    return follow(session(), "GET", path, **kw)
