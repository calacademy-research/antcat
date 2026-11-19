# Release gate (AntCat)

May a pull request be merged to master? The same gate as AntWeb's (calacademy-research/antweb, `tools/release/`),
with AntCat's workflows. Road map step 5 (D5), 2026-11-19.

    python3 tools/release/gate.py PR_NUMBER [--no-review "reason"]

| # | Check | Passes when |
|---|---|---|
| 1 | ci | The `Main` workflow passed on the PR head. |
| 2 | staging | The newest `Deploy staging` run of a commit with the head's files (same git tree) succeeded and its end-to-end job ran and passed. A run that found staging held deployed nothing and does not count. A PR that changes only docs, specs, CI files or release tools needs no staging run. |
| 3 | review | The latest Claude review is for the head commit and starts "No blocking issues" (`--no-review "reason"` when there is none). |
| 4 | window | Not between 02:45 and 03:45 Pacific: antcat-export copies the database at 03:00 for AntWeb. |
| 5 | rollback | The PR text has a `Rollback:` line. |

`.github/workflows/release-gate.yml` runs the gate for every open pull request and writes the commit status
`release-gate` (green: GATE OPEN). It runs on PR events, after Main, Deploy staging, the end-to-end tests and the
Claude review, and every hour. The gate's code always comes from master (`pull_request_target`), so a PR cannot change
what writes its own status. Limit: a branch of this repository could add another workflow that writes a status
or a comment in the review's name with its own token (both come from the GitHub Actions app). Before the status
becomes a required check, changes to `.github/workflows/` should be limited to the maintainers (CODEOWNERS or a
ruleset, a repository setting); until then the gate relies on only maintainers pushing branches here. AntWeb's gate
has the same limit.

## Merging a pull request

1. CI (`Main`) green and the Claude review read.
2. Check the coordination board (AntWeb and AntCat chats share antcat-staging), then put the head on staging:
   `git push -f origin <head sha>:staging`. Deploy staging deploys it and runs the end-to-end tests.
3. `python3 tools/release/gate.py N`: GATE OPEN.
4. Merge, then deploy by hand (`script/deploy`, staging first) until production deploys itself (road map D4).

Tests: `python3 -m unittest tools/release/test_gate.py` (also in CI).
