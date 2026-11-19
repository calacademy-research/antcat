"""Tests of the AntCat release gate (tools/release/gate.py, gate_targets.py). Run: python3 -m unittest tools/release/test_gate.py"""
import datetime as dt
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import gate  # noqa: E402
import gate_targets  # noqa: E402

TREES = {"head": "T1", "ours": "T1", "other": "T2"}
tree_of = TREES.__getitem__


def run(sha, created, conclusion="success", status="completed", rid=1):
    return {"head_sha": sha, "created_at": created, "conclusion": conclusion, "status": status, "id": rid}


class StagingTest(unittest.TestCase):
    def test_the_newest_deploy_of_the_heads_tree_counts(self):
        runs = [run("ours", "2026-11-19T10:00:00Z", rid=1), run("other", "2026-11-19T11:00:00Z", rid=2),
                run("head", "2026-11-19T09:00:00Z", "failure", rid=3)]
        self.assertEqual(1, gate.staged_run("T1", runs, tree_of)["id"])
        # a failed redeploy of the same tree after the good one decides
        runs.append(run("head", "2026-11-19T12:00:00Z", "failure", rid=4))
        self.assertEqual(4, gate.staged_run("T1", runs, tree_of)["id"])
        self.assertIsNone(gate.staged_run("T9", runs, tree_of))
        # a run still in progress does not count
        self.assertIsNone(gate.staged_run("T2", [run("other", "x", None, "in_progress")], tree_of))
        # the tree from the run itself, when GitHub gives it (no lookup)
        own = dict(run("unknown-sha", "2026-11-19T13:00:00Z", rid=5), head_commit={"tree_id": "T7"})
        self.assertEqual(5, gate.staged_run("T7", [own], tree_of)["id"])

    def test_a_later_push_before_the_run_finished(self):
        a = dict(run("head", "2026-11-19T10:00:00Z", rid=1), updated_at="2026-11-19T10:20:00Z")
        b = dict(run("other", "2026-11-19T10:05:00Z", rid=2), updated_at="2026-11-19T10:40:00Z")
        later = dict(run("other", "2026-11-19T10:30:00Z", rid=3), updated_at="2026-11-19T10:50:00Z")
        self.assertTrue(gate.followed_by_push(a, [a, b]))            # b may have been what a deployed
        self.assertFalse(gate.followed_by_push(a, [a, later]))       # pushed after a had finished
        self.assertFalse(gate.followed_by_push(b, [a, b]))           # an earlier run does not matter
        ok, text = gate.staging_state(a, [], followed=True)
        self.assertFalse(ok)
        self.assertIn("another push", text)

    def test_staging_state(self):
        good = run("head", "t", rid=7)
        tests = [{"name": "Run the tests", "conclusion": "success"}]
        e2e_ok = [{"name": "Deploy origin/staging to antcat-staging", "conclusion": "success"},
                  {"name": "e2e / End-to-end tests against antcat-staging", "conclusion": "success", "steps": tests}]
        self.assertTrue(gate.staging_state(good, e2e_ok)[0])
        held = [e2e_ok[0], dict(e2e_ok[1], conclusion="skipped")]
        ok, text = gate.staging_state(good, held)
        self.assertFalse(ok)
        self.assertIn("held", text)
        self.assertFalse(gate.staging_state(good, e2e_ok[:1])[0])          # no end-to-end job at all
        no_secrets = [e2e_ok[0], dict(e2e_ok[1], steps=[{"name": "Run the tests", "conclusion": "skipped"}])]
        self.assertFalse(gate.staging_state(good, no_secrets)[0])          # green job, tests skipped
        self.assertFalse(gate.staging_state(good, [e2e_ok[0], dict(e2e_ok[1], conclusion="failure")])[0])
        self.assertFalse(gate.staging_state(run("head", "t", "failure"), e2e_ok)[0])
        self.assertFalse(gate.staging_state(None, [])[0])

    def test_no_site_code(self):
        self.assertTrue(gate.no_site_code(["spec/models/taxon_spec.rb", "README.md", ".github/workflows/main.yml"]))
        self.assertFalse(gate.no_site_code([".github/workflows/deploy-staging.yml"]))   # proved by a staging run
        self.assertFalse(gate.no_site_code([".github/workflows/e2e-staging.yml"]))
        self.assertFalse(gate.no_site_code(["app/views/help/notes.md"]))   # Markdown inside the app
        self.assertFalse(gate.no_site_code(["config/specials.yml"]))
        self.assertFalse(gate.no_site_code(["app/models/taxon.rb", "spec/models/taxon_spec.rb"]))
        self.assertFalse(gate.no_site_code(["e2e/test_api.py"]))   # proved only by running them on staging
        self.assertFalse(gate.no_site_code([]))


class OtherChecksTest(unittest.TestCase):
    def test_review(self):
        bot = {"login": "github-actions[bot]"}
        ok = {"user": bot, "body": "<!-- claude-review -->\n### Claude review\n\nNo blocking issues\n\n"
                                   "<sub>Automatic review of abc1234 by `m`.</sub>"}
        self.assertTrue(gate.review_state([ok], "abc1234ffff")[0])
        self.assertFalse(gate.review_state([ok], "def5678")[0])                       # an older commit
        fake = dict(ok, user={"login": "someone"})
        self.assertFalse(gate.review_state([fake], "abc1234")[0])                     # not the review workflow
        blocking = dict(ok, body=ok["body"].replace("No blocking issues", "Blocking: SQL injection"))
        self.assertFalse(gate.review_state([ok, blocking], "abc1234")[0])             # the latest one counts
        self.assertFalse(gate.review_state([], "abc1234")[0])
        quoted = dict(ok, body=ok["body"].replace("No blocking issues\n", "No blocking issues\nAs the last Automatic review of 9999999 said.\n"))
        self.assertTrue(gate.review_state([quoted], "abc1234")[0])                    # the footer counts, not a quote

    def test_window_around_the_export(self):
        at = lambda h, m: dt.datetime(2026, 11, 19, h, m, tzinfo=gate.PACIFIC)
        self.assertTrue(gate.window_closed(at(3, 0)))
        self.assertTrue(gate.window_closed(at(2, 45)))
        self.assertFalse(gate.window_closed(at(3, 45)))
        self.assertFalse(gate.window_closed(at(14, 0)))
        summer = dt.datetime(2026, 7, 1, 10, 0, tzinfo=dt.timezone.utc)   # 03:00 Pacific daylight time
        self.assertTrue(gate.window_closed(summer))

    def test_rollback_line(self):
        self.assertTrue(gate.has_rollback("Text\n\nRollback: revert the merge commit"))
        self.assertTrue(gate.has_rollback("- **Rollback:** script/deploy --rollback"))
        self.assertFalse(gate.has_rollback("no way back"))
        self.assertFalse(gate.has_rollback(None))
        self.assertFalse(gate.has_rollback("Rollback:"))
        self.assertFalse(gate.has_rollback("Rollback:  \nnext line"))


class TargetsTest(unittest.TestCase):
    def test_targets(self):
        open_prs = {1630: "aaa", 1631: "bbb"}
        t = gate_targets.targets
        self.assertEqual([1630], t("pull_request_target", "1630", [], "", open_prs))
        self.assertEqual([], t("pull_request_target", "999", [], "", open_prs))
        self.assertEqual([1631], t("workflow_run", "", [{"number": 1631}], "zzz", open_prs))
        self.assertEqual([1630], t("workflow_run", "", [], "aaa", open_prs))
        self.assertEqual([1630, 1631], t("workflow_run", "", [], "zzz", open_prs))   # a staging deploy of no PR head
        self.assertEqual([1630, 1631], t("schedule", "", [], "", open_prs))


if __name__ == "__main__":
    unittest.main()
