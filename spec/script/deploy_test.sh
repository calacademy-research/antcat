#!/usr/bin/env bash
# Tests for script/deploy without a server: a real git repository with a local "GitHub" (bare
# repository) and a fake `docker` on PATH that records its calls and answers health checks.
# Run: spec/script/deploy_test.sh   (CI runs it with shellcheck in .github/workflows/main.yml)
set -uo pipefail

DEPLOY="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/script/deploy"
FAILS=0
TESTS=0

fail() { echo "  FAIL: $*"; FAILS=$((FAILS + 1)); }
ok() { echo "  ok: $*"; }
not() { ! "$@"; }
check() { # check "description" command...
  local desc="$1"; shift
  if "$@"; then ok "$desc"; else fail "$desc"; fi
}

# Builds a fresh sandbox: $ORIGIN (bare), $SERVER (checkout at commit A, detached like staging),
# $BIN with the fake docker. Sets $A.
setup() {
  TESTS=$((TESTS + 1))
  echo "TEST: $1"
  T="$(mktemp -d)"
  ORIGIN="$T/origin.git"; SERVER="$T/server"; BIN="$T/bin"; WORK="$T/work"
  git init -q --bare -b master "$ORIGIN"
  git init -q -b master "$WORK"
  git -C "$WORK" config user.email t@example.org; git -C "$WORK" config user.name test
  mkdir -p "$WORK/db/migrate" "$WORK/dockerized_app" "$WORK/app/models"
  echo "FROM ruby" > "$WORK/dockerized_app/Dockerfile"
  echo "services: {}" > "$WORK/dockerized_app/docker-compose.yml"
  echo "class Taxon; end" > "$WORK/app/models/taxon.rb"
  git -C "$WORK" add -A; git -C "$WORK" commit -qm "A: start"
  git -C "$WORK" remote add origin "$ORIGIN"; git -C "$WORK" push -q origin master
  A="$(git -C "$WORK" rev-parse HEAD)"
  git clone -q "$ORIGIN" "$SERVER"
  git -C "$SERVER" checkout -q --detach

  mkdir -p "$BIN"
  cat > "$BIN/docker" <<'FAKE'
#!/usr/bin/env bash
echo "docker $*" >> "$DOCKER_LOG"
case "$1" in
  inspect) echo true ;;
  logs) echo "fake app log" ;;
  restart) exit "${FAKE_RESTART_RC:-0}" ;;
  compose) [[ "$*" == *build* ]] && exit "${FAKE_BUILD_RC:-0}" ;;
  exec)
    if [[ "$*" == *db:migrate* ]]; then exit "${FAKE_MIGRATE_RC:-0}"; fi
    if [[ "$*" == *curl* && "$*" == *http_code* ]]; then
      # FAKE_DOWN_CALLS: the first N health requests find nothing listening (curl prints 000, exits 7).
      n=$(( $(cat "$DOCKER_LOG.down" 2> /dev/null || echo 0) + 1 )); echo "$n" > "$DOCKER_LOG.down"
      if [ "$n" -le "${FAKE_DOWN_CALLS:-0}" ]; then printf 000; exit 7; fi
      echo "${FAKE_HTTP:-200}"; exit 0
    fi
    if [[ "$*" == *curl* ]]; then
      c="$(git -C "$ANTCAT_DIR" rev-parse HEAD)"
      echo "<footer><a href=\"https://github.com/calacademy-research/antcat/commit/$c\" title=\"Deployed commit on GitHub\">${c:0:7}</a></footer>"
      exit 0
    fi ;;
esac
exit 0
FAKE
  chmod +x "$BIN/docker"
  export PATH="$BIN:$PATH" DOCKER_LOG="$T/docker.log" ANTCAT_DIR="$SERVER"
  export ANTCAT_ROLLBACK_FILE="$T/rollback.txt" ANTCAT_DEPLOY_LOG="$T/deploy.log"
  export ANTCAT_LOCK_FILE="$T/lock" ANTCAT_HEALTH_INTERVAL=1
  unset FAKE_HTTP FAKE_MIGRATE_RC FAKE_RESTART_RC FAKE_BUILD_RC FAKE_DOWN_CALLS
  : > "$DOCKER_LOG"
}

# Adds a commit on GitHub touching the given path.
push_change() { # push_change path message
  mkdir -p "$(dirname "$WORK/$1")"
  echo "$RANDOM" >> "$WORK/$1"
  git -C "$WORK" add -A; git -C "$WORK" commit -qm "$2"; git -C "$WORK" push -q origin master
  git -C "$WORK" rev-parse HEAD
}

run() { OUT="$("$DEPLOY" "$@" 2>&1)"; RC=$?; }
head_is() { [ "$(git -C "$SERVER" rev-parse HEAD)" = "$1" ]; }
docker_called() { grep -q -- "$1" "$DOCKER_LOG"; }
out_has() { grep -q -- "$1" <<< "$OUT"; }
show() { [ -n "${SHOW:-}" ] && echo "$OUT"; return 0; }
teardown() { [ "$FAILS" -gt 0 ] && [ -n "${KEEP:-}" ] && return; rm -rf "$T"; }

setup "refuses when tracked files have local changes"
B="$(push_change app/models/taxon.rb "B: model change")"
echo "local edit" >> "$SERVER/app/models/taxon.rb"
run
check "exits non-zero" [ "$RC" -ne 0 ]
check "says why" out_has "local changes"
check "did not move HEAD" head_is "$A"
check "no docker calls" [ ! -s "$DOCKER_LOG" ]
check "no rollback file" [ ! -e "$ANTCAT_ROLLBACK_FILE" ]
teardown

setup "dry run shows the plan and changes nothing"
push_change app/models/taxon.rb "B: model change" > /dev/null
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "C: add api keys")"
run --dry-run
check "exits 0" [ "$RC" -eq 0 ]
check "lists the commits" out_has "C: add api keys"
check "reports migrations" out_has "db/migrate  *YES"
check "reports no Dockerfile change" out_has "Dockerfile  *no"
check "did not move HEAD" head_is "$A"
check "no restart" not docker_called restart
check "no rollback file" [ ! -e "$ANTCAT_ROLLBACK_FILE" ]
teardown

setup "plain deploy: restart, health check, rollback commit saved"
B="$(push_change app/models/taxon.rb "B: model change")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the new commit" head_is "$B"
check "stays detached (staging style)" [ -z "$(git -C "$SERVER" symbolic-ref -q HEAD)" ]
check "rollback file holds the old commit" [ "$(cat "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
check "restarted the app" docker_called "restart antcat-app"
check "no rebuild" not docker_called "compose build"
check "no migration" not docker_called "db:migrate"
check "health check on the local port" docker_called "http://127.0.0.1:8080/v1/taxa/429011"
check "prints the deployed commit" out_has "DEPLOYED $B"
show; check "prints a server log entry" out_has "Server log entry:"
check "writes the deploy log" grep -q "deploy OK" "$ANTCAT_DEPLOY_LOG"
teardown

setup "already up to date: nothing happens"
run
check "exits 0" [ "$RC" -eq 0 ]
check "says nothing to deploy" out_has "nothing to deploy"
check "no restart" not docker_called restart
teardown

setup "migrations run as the app user, then a second restart"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "ran db:migrate as antcat" docker_called "exec -u antcat .* antcat-app bundle exec rails db:migrate"
check "restarted twice" [ "$(grep -c 'restart antcat-app' "$DOCKER_LOG")" -eq 2 ]
check "server log entry says migrations: yes" out_has "migrations: yes"
teardown

setup "failed migration stops with the rollback command and a warning"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
export FAKE_MIGRATE_RC=1
run
check "exits non-zero" [ "$RC" -ne 0 ]
check "prints the manual rollback command" out_has "git checkout -q $A && docker restart antcat-app"
check "suggests --rollback --yes" out_has "script/deploy --rollback --yes"
check "warns that migrations ran" out_has "MIGRATIONS RAN"
check "did not roll back by itself" head_is "$B"
teardown

setup "Dockerfile change rebuilds the image and reloads nginx"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "built the image" docker_called "compose .*build app"
check "recreated only the app container" docker_called "compose .*up -d --no-deps app"
check "did not just restart" not docker_called "restart antcat-app"
check "reloaded nginx" docker_called "nginx -s reload"
teardown

setup "failed health check: no automatic rollback, prints the rollback command"
B="$(push_change app/models/taxon.rb "B: broken")"
export FAKE_HTTP=500
run --timeout 3
check "exits non-zero" [ "$RC" -ne 0 ]
check "says the health check failed" out_has "HEALTH CHECK FAILED"
check "prints the rollback command" out_has "git checkout -q $A && docker restart antcat-app"
check "new code stays checked out" head_is "$B"
check "no migration warning" not out_has "MIGRATIONS RAN"
teardown

setup "rollback goes back to the saved commit"
B="$(push_change app/models/taxon.rb "B: model change")"
run
run --rollback
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the old commit" head_is "$A"
check "restarted" [ "$(grep -c 'restart antcat-app' "$DOCKER_LOG")" -eq 2 ]
check "says rolled back" out_has "ROLLED BACK to $A"
teardown

setup "rollback across migrations needs --yes"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
run
run --rollback
check "refuses without --yes" [ "$RC" -ne 0 ]
check "still at the new commit" head_is "$B"
run --rollback --yes
check "rolls back with --yes" head_is "$A"
teardown

setup "branch checkout (production style) is fast-forwarded and stays on master"
git -C "$SERVER" checkout -q master
B="$(push_change app/models/taxon.rb "B: model change")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the new commit" head_is "$B"
check "still on branch master" [ "$(git -C "$SERVER" symbolic-ref -q --short HEAD)" = master ]
run --ref some-branch
check "refuses another ref on a branch checkout" [ "$RC" -ne 0 ]
teardown

setup "--ref deploys another branch on a detached checkout"
git -C "$WORK" checkout -q -b feature
echo x > "$WORK/feature.txt"; git -C "$WORK" add -A; git -C "$WORK" commit -qm "F: feature"
git -C "$WORK" push -q origin feature
F="$(git -C "$WORK" rev-parse HEAD)"
run --ref feature
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the feature commit" head_is "$F"
teardown

setup "refuses when the deploy log cannot be written"
B="$(push_change app/models/taxon.rb "B: model change")"
export ANTCAT_DEPLOY_LOG="$T/no-such-dir/deploy.log"
run
check "exits non-zero" [ "$RC" -ne 0 ]
check "did not move HEAD" head_is "$A"
teardown

setup "unexpected error after the checkout still prints the rollback command"
B="$(push_change app/models/taxon.rb "B: model change")"
export FAKE_RESTART_RC=1
run
check "exits non-zero" [ "$RC" -ne 0 ]
check "says unexpected error" out_has "UNEXPECTED ERROR"
check "prints the rollback command" out_has "git checkout -q $A && docker restart antcat-app"
check "logged the failure" grep -q "deploy FAILED (unexpected error" "$ANTCAT_DEPLOY_LOG"
teardown

setup "rollback on a branch checkout: the next deploy goes back onto master"
git -C "$SERVER" checkout -q master
B="$(push_change app/models/taxon.rb "B: broken")"
run
run --rollback
check "rolled back" head_is "$A"
run --ref some-branch
check "refuses another ref after a production rollback" [ "$RC" -ne 0 ]
C="$(push_change app/models/taxon.rb "C: fixed")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the fix" head_is "$C"
check "back on branch master" [ "$(git -C "$SERVER" symbolic-ref -q --short HEAD)" = master ]
teardown

setup "rollback across a Dockerfile change rebuilds and reloads nginx"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
run
: > "$DOCKER_LOG"
run --rollback
check "exits 0" [ "$RC" -eq 0 ]
check "rebuilt the image" docker_called "compose .*build app"
check "reloaded nginx" docker_called "nginx -s reload"
teardown

setup "after a failed deploy the rollback commit stays the last good one"
B="$(push_change app/models/taxon.rb "B: broken")"
export FAKE_HTTP=500
run --timeout 2
unset FAKE_HTTP
C="$(push_change app/models/taxon.rb "C: fixed")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "rollback file still holds A" [ "$(cat "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
teardown

setup "retry after a failed image build rebuilds again"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
export FAKE_BUILD_RC=1
run
check "first run fails" [ "$RC" -ne 0 ]
check "suggests script/deploy --rollback, not a plain restart" out_has "use script/deploy --rollback"
check "error reported once" [ "$(grep -c "UNEXPECTED ERROR" <<< "$OUT")" -eq 1 ]
unset FAKE_BUILD_RC
: > "$DOCKER_LOG"
run
check "retry exits 0" [ "$RC" -eq 0 ]
check "retry rebuilt the image" docker_called "compose .*build app"
check "rollback file still holds A" [ "$(cat "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
teardown

setup "retry after a failed migration runs the migrations again"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
export FAKE_MIGRATE_RC=1
run
check "first run fails" [ "$RC" -ne 0 ]
unset FAKE_MIGRATE_RC
C="$(push_change app/models/taxon.rb "C: fix the model the migration uses")"
: > "$DOCKER_LOG"
run
check "retry exits 0" [ "$RC" -eq 0 ]
check "retry ran db:migrate" docker_called "db:migrate"
check "HEAD is the fix" head_is "$C"
teardown

setup "migrations wait until Puma really answers"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
export FAKE_DOWN_CALLS=3
run
check "exits 0" [ "$RC" -eq 0 ]
check "waited through the connection failures" [ "$(grep -c http_code "$DOCKER_LOG")" -ge 4 ]
check "migrated after Puma answered" [ "$(grep -n -m1 db:migrate "$DOCKER_LOG" | cut -d: -f1)" -gt 4 ]
teardown

setup "an interrupted deploy counts as failed"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
echo "$A" > "$ANTCAT_ROLLBACK_FILE"
git -C "$SERVER" checkout -q "$B"
echo "2026-11-09 10:00:00 PST test deploy start a -> b ref=master changes=dockerfile" > "$ANTCAT_DEPLOY_LOG"
run
check "exits 0" [ "$RC" -eq 0 ]
check "says the last deploy failed" out_has "the last deploy failed"
check "rebuilt the image" docker_called "compose .*build app"
check "rollback file still holds A" [ "$(cat "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
teardown

setup "a failed rollback can be run again"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
run
export FAKE_BUILD_RC=1
run --rollback
check "rollback fails" [ "$RC" -ne 0 ]
check "logged rollback FAILED" grep -q "rollback FAILED" "$ANTCAT_DEPLOY_LOG"
unset FAKE_BUILD_RC
: > "$DOCKER_LOG"
run --rollback
check "retry exits 0" [ "$RC" -eq 0 ]
check "retry rebuilt the image" docker_called "compose .*build app"
check "HEAD is A" head_is "$A"
teardown

setup "on a branch checkout the failure message gives only script/deploy --rollback"
git -C "$SERVER" checkout -q master
B="$(push_change app/models/taxon.rb "B: broken")"
export FAKE_HTTP=500
run --timeout 2
check "exits non-zero" [ "$RC" -ne 0 ]
check "no manual git checkout line" not out_has "git checkout -q $A"
check "points to script/deploy --rollback" out_has "script/deploy --rollback"
teardown

setup "a failed rollback after a failed deploy: the next deploy still starts from the good commit"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
export FAKE_MIGRATE_RC=1
run
unset FAKE_MIGRATE_RC
echo "2026-11-09 10:00:00 PST test rollback FAILED (unexpected error)" >> "$ANTCAT_DEPLOY_LOG"
C="$(push_change app/models/taxon.rb "C: fix")"
: > "$DOCKER_LOG"
run
check "exits 0" [ "$RC" -eq 0 ]
check "ran db:migrate" docker_called "db:migrate"
check "rollback file still holds A" [ "$(cat "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
teardown

echo
echo "$TESTS tests, $FAILS failed checks"
[ "$FAILS" -eq 0 ]
