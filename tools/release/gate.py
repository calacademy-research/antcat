#!/usr/bin/env python3
"""Release gate for AntCat: may this pull request be merged to master?

    python3 tools/release/gate.py PR_NUMBER [--no-review "reason"]

Prints one line per check and then GATE OPEN or GATE CLOSED (exit 0 or 1). The same gate as AntWeb's (Brian Fisher,
2026-11-05; road map step 5, AntCat step D5, 2026-11-19), with AntCat's workflows. Docs: tools/release/README.md.

 1. ci        The "Main" workflow (RSpec, RuboCop, migrations, security scan, container build) passed on the PR head.
 2. staging   antcat-staging ran the PR's code and the end-to-end tests passed against it: the newest "Deploy staging"
              run of a commit with the PR head's files (the same git tree: Claude pushes the head to the branch
              `staging`) succeeded, and its end-to-end job ran and passed. A run that found staging held (the AntCat
              chat's hold file) deployed nothing and does not count. A PR that changes only files outside the site
              (NO_SITE_PATHS: docs, specs, CI files, release tools) needs no staging run.
 3. review    The latest Claude review comment is for the head commit and starts "No blocking issues";
              --no-review "reason" when there is none.
 4. window    Not between 02:45 and 03:45 Pacific: antcat-export copies the database at 03:00 for AntWeb's 05:00
              import, and production must not change under it (it matters once merging deploys production, D4).
 5. rollback  The PR text has a "Rollback:" line.

Read-only: it reads the GitHub API (through the gh command line tool) and nothing else.
"""
import argparse
import datetime as dt
import fnmatch
import json
import re
import subprocess
import sys
from zoneinfo import ZoneInfo

REPO = "calacademy-research/antcat"
PACIFIC = ZoneInfo("America/Los_Angeles")
REVIEW_MARKER = "<!-- claude-review -->"
REVIEW_BOT = "github-actions[bot]"   # the account the review workflow posts as
CLOSED_FROM = dt.time(2, 45)
CLOSED_UNTIL = dt.time(3, 45)
STAGING_HISTORY = 30   # staging deploys read for check 2 (the newest ones)
E2E_JOB = "End-to-end"   # the end-to-end job of a Deploy staging run has this in its name

# Files that are not part of the running site: changing only these needs no staging run. The end-to-end tests
# themselves (e2e/) are not here: a change to them is proved by running them against staging.
NO_SITE_PATHS = [
    "doc/*", "docs/*", "*.md", "spec/*", ".github/*", "tools/release/*", ".rubocop*", "release-notes/*",
]


# ---- the checks, as plain functions (tools/release/test_gate.py) ----

def no_site_code(files):
    """True when every changed file is outside the site (NO_SITE_PATHS): staging has nothing to run."""
    return bool(files) and all(any(fnmatch.fnmatch(f, p) for p in NO_SITE_PATHS) for f in files)


def staged_run(head_tree, staging_runs, tree_of):
    """The newest finished Deploy staging run whose commit has the PR head's tree, or None (a failed or newer
    redeploy of the same tree decides: the newest one counts)."""
    for run in sorted(staging_runs, key=lambda r: r.get("created_at") or "", reverse=True):
        if run.get("status", "completed") == "completed" and tree_of(run["head_sha"]) == head_tree:
            return run
    return None


def staging_state(run, jobs):
    """(ok, text) for a Deploy staging run and its jobs: it succeeded, and its end-to-end job ran and passed."""
    if run is None:
        return False, "no staging deploy of the head's files (push the head to the branch staging)"
    if run.get("conclusion") != "success":
        return False, f"the last staging deploy of the head's files ended {run.get('conclusion')} (run {run.get('id')})"
    e2e = [j for j in jobs if E2E_JOB in (j.get("name") or "")]
    if not e2e or any(j.get("conclusion") == "skipped" for j in e2e):
        return False, f"run {run.get('id')} deployed nothing or skipped its end-to-end tests (staging held?)"
    if not all(j.get("conclusion") == "success" for j in e2e):
        return False, f"end-to-end tests {', '.join(sorted({str(j.get('conclusion')) for j in e2e}))} (run {run.get('id')})"
    return True, f"deployed to staging and end-to-end tests passed (run {run.get('id')})"


def review_state(comments, head_sha):
    """(ok, text) for the latest Claude review comment of the PR."""
    reviews = [c for c in comments if (c.get("body") or "").startswith(REVIEW_MARKER)
               and (c.get("user") or {}).get("login") == REVIEW_BOT]
    if not reviews:
        return False, "no Claude review comment"
    body = reviews[-1]["body"]
    m = re.search(r"Automatic review of ([0-9a-f]{7,40})", body)
    if not m or not head_sha.startswith(m.group(1)):
        return False, f"the review is of {m.group(1) if m else 'an unknown commit'}, not the head {head_sha[:7]}"
    text = body[len(REVIEW_MARKER):].replace("### Claude review", "", 1).strip()
    if not text.startswith("No blocking issues"):
        return False, "the review lists blocking issues: " + text.splitlines()[0][:120]
    return True, f"no blocking issues ({head_sha[:7]})"


def window_closed(now):
    """True between 02:45 and 03:45 Pacific (the export copies the database at 03:00)."""
    t = now.astimezone(PACIFIC).time()
    return CLOSED_FROM <= t < CLOSED_UNTIL


def has_rollback(body):
    return bool(re.search(r"(?im)^\W*rollback\W*:", body or ""))


# ---- GitHub ----

def gh(path):
    out = subprocess.run(["gh", "api", path], capture_output=True, text=True, check=True).stdout
    return json.loads(out) if out.strip() else None


def gh_all(path, key=None):
    """Every page of a list; key: the list inside each page's object ("workflow_runs", "jobs"), None for a plain list."""
    out = subprocess.run(["gh", "api", "--paginate", path], capture_output=True, text=True, check=True).stdout
    items, dec, i = [], json.JSONDecoder(), 0
    while i < len(out):
        while i < len(out) and out[i].isspace():
            i += 1
        if i >= len(out):
            break
        page, i = dec.raw_decode(out, i)
        items += (page.get(key) or []) if key else (page or [])
    return items


_TREES = {}


def tree_of(sha):
    if sha not in _TREES:
        _TREES[sha] = gh(f"repos/{REPO}/commits/{sha}")["commit"]["tree"]["sha"]
    return _TREES[sha]


def runs_for(sha, name):
    runs = gh_all(f"repos/{REPO}/actions/runs?head_sha={sha}&per_page=100", "workflow_runs")
    return sorted([r for r in runs if r["name"] == name], key=lambda r: r["created_at"])


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("pr", type=int)
    ap.add_argument("--no-review", metavar="REASON", help="no Claude review, and why (check 3)")
    args = ap.parse_args(argv)

    pr = gh(f"repos/{REPO}/pulls/{args.pr}")
    head = pr["head"]["sha"]
    files = [f["filename"] for f in gh_all(f"repos/{REPO}/pulls/{args.pr}/files?per_page=100")]
    results = []

    def check(n, name, ok, text):
        results.append(ok)
        print(f"{n} {name:9} {'PASS' if ok else 'FAIL'}  {text}")

    print(f"Release gate, AntCat PR #{args.pr} ({pr['title']}), head {head[:7]}, "
          f"{dt.datetime.now(PACIFIC):%Y-%m-%d %H:%M} Pacific")

    ci = runs_for(head, "Main")
    check(1, "ci", bool(ci) and ci[-1]["conclusion"] == "success",
          f"Main {ci[-1]['conclusion'] or ci[-1]['status']}" if ci else "no Main run for the head")

    if no_site_code(files):
        check(2, "staging", True, "no site code changed: no staging run needed")
    else:
        deploys = gh(f"repos/{REPO}/actions/workflows/deploy-staging.yml/runs?branch=staging&per_page={STAGING_HISTORY}")["workflow_runs"]
        run = staged_run(tree_of(head), deploys, tree_of)
        jobs = gh_all(f"repos/{REPO}/actions/runs/{run['id']}/jobs?per_page=100", "jobs") if run else []
        check(2, "staging", *staging_state(run, jobs))

    if args.no_review:
        check(3, "review", True, f"no review: {args.no_review}")
    else:
        comments = gh_all(f"repos/{REPO}/issues/{args.pr}/comments?per_page=100")
        check(3, "review", *review_state(comments, head))

    closed = window_closed(dt.datetime.now(dt.timezone.utc))
    check(4, "window", not closed, "02:45 to 03:45 Pacific: the AntWeb export copies the database" if closed
          else "outside the export window (02:45 to 03:45 Pacific)")

    check(5, "rollback", has_rollback(pr.get("body")), "Rollback: line found" if has_rollback(pr.get("body"))
          else "no 'Rollback:' line in the PR text")

    ok = all(results)
    print("GATE OPEN" if ok else "GATE CLOSED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
