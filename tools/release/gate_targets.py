"""Which open pull requests a run of the Release gate workflow gates (.github/workflows/release-gate.yml).

A PR event gates that PR. A finished run (Main, Deploy staging, End-to-end tests (staging), Claude review) gates the PRs GitHub names
for it, else the open PR whose head is the run's commit; when neither (a Deploy staging run of a commit no open PR has as its
head) every open PR. The hourly runs and a manual run gate every open PR. Review of
#375: re-gating every PR on every event could reach GITHUB_TOKEN's hourly request limit.

    gate_targets.py EVENT EVENT_PR RUN_PRS_JSON RUN_SHA  < "number head_sha" lines of the open PRs
prints the PR numbers, one line, space separated. Tests: tools/release/test_gate.py (copied from AntWeb, 2026-11-19).
"""
import json
import sys


def targets(event, event_pr, run_prs, run_sha, open_prs):
    """open_prs: {number: head sha} of the open PRs into master. Returns the numbers to gate, in order."""
    every = sorted(open_prs)
    if event == "pull_request_target":
        try:
            number = int(event_pr)
        except (TypeError, ValueError):
            return every
        return [number] if number in open_prs else []
    if event == "workflow_run":
        named = sorted({p.get("number") for p in (run_prs or []) if isinstance(p, dict) and p.get("number") in open_prs})
        if named:
            return named
        by_head = sorted(n for n, sha in open_prs.items() if run_sha and sha == run_sha)
        return by_head or every
    return every


def read_open(lines):
    found = {}
    for line in lines:
        parts = line.split()
        if len(parts) >= 2 and parts[0].isdigit():
            found[int(parts[0])] = parts[1]
    return found


def main(argv, stdin):
    event, event_pr, run_prs, run_sha = (argv + ["", "", "[]", ""])[:4]
    try:
        prs = json.loads(run_prs or "[]")
    except ValueError:
        prs = []
    print(" ".join(str(n) for n in targets(event, event_pr, prs if isinstance(prs, list) else [], run_sha, read_open(stdin))))


if __name__ == "__main__":
    main(sys.argv[1:], sys.stdin.read().splitlines())
