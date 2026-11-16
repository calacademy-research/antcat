"""Signing in (e2e/README.md): the page has its form and token; with the test editor account (staging only) the
sign-in works and the editor's panel opens. The only POST of these tests."""
import re

import pytest

from conftest import EDITOR_EMAIL, EDITOR_PASSWORD, follow, session


def form_token(html):
    m = re.search(r'name="authenticity_token" value="([^"]+)"', html)
    assert m, "no CSRF token on the sign-in page"
    return m.group(1)


def test_sign_in_page_has_its_form():
    r = follow(session(), "GET", "/users/sign_in")
    assert r.status_code == 200, r.status_code
    assert 'name="user[email]"' in r.text and 'name="user[password]"' in r.text
    form_token(r.text)


@pytest.mark.skipif(not (EDITOR_EMAIL and EDITOR_PASSWORD), reason="test editor account not set")
def test_editor_signs_in_and_opens_the_panel():
    s = session()
    page = follow(s, "GET", "/users/sign_in")
    r = follow(s, "POST", "/users/sign_in",
               data={"authenticity_token": form_token(page.text), "user[email]": EDITOR_EMAIL, "user[password]": EDITOR_PASSWORD})
    assert r.status_code == 200, r.status_code
    assert "Logout" in r.text, "not signed in"
    panel = follow(s, "GET", "/panel")
    assert panel.status_code == 200, panel.status_code
