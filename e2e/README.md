# End-to-end tests against a running AntCat

Read-only checks of a running site (antcat-staging through an SSH tunnel in CI): pages people use, search, references,
the /v1 API with and without a key, the sign-in page and, when a test account is given, an editor's sign-in. Every
request is a GET except the one sign-in POST, which updates the test account's sign-in fields (count, time, address)
and, with a wrong password, its failed attempts. The suite refuses to start when ANTCAT_URL is antcat.org. Never pointed at antcat.org by CI: they run on staging after a staging deploy, or by hand
(.github/workflows/e2e-staging.yml; road map step D3, 2026-11-16). Redirects are followed only within the site under test.

    ANTCAT_URL=https://staging.example python3 -m pytest e2e -q

| Variable | Use |
|---|---|
| `ANTCAT_URL` | the site (required; without it every test is skipped) |
| `ANTCAT_HOST_HEADER` | the Host header to send, when the tunnel's address is not the site's name |
| `ANTCAT_TEST_API_KEY` | an API key of the site, for the /v1 tests that need one (skipped without) |
| `ANTCAT_TEST_EDITOR_EMAIL`, `ANTCAT_TEST_EDITOR_PASSWORD` | a test editor account (sign-in test skipped without) |
| `ANTCAT_ENVIRONMENT` | must be `staging` for the sign-in test (it writes to the user row) |
