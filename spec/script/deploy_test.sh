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
  compose)
    [[ "$*" == *build* ]] && exit "${FAKE_BUILD_RC:-0}"
    # The throwaway nginx config test (compose run ... web nginx -t).
    if [[ "$*" == *" run "*"web nginx -t" ]]; then echo "nginx: fake config test"; exit "${FAKE_NGINX_TEST_RC:-0}"; fi
    [[ "$*" == *"nginx -s reload" ]] && exit "${FAKE_NGINX_RELOAD_RC:-0}"
    [[ "$*" == *"--force-recreate"*" web" ]] && exit "${FAKE_NGINX_RECREATE_RC:-0}" ;;
  exec)
    if [[ "$*" == *db:migrate* ]]; then exit "${FAKE_MIGRATE_RC:-0}"; fi
    if [[ "$*" == *"bundle check"* ]]; then
      # FAKE_GEMS_MISSING_CALLS: the first N checks run while startup.sh is still installing gems.
      n=$(( $(cat "$DOCKER_LOG.gems" 2> /dev/null || echo 0) + 1 )); echo "$n" > "$DOCKER_LOG.gems"
      [ "$n" -le "${FAKE_GEMS_MISSING_CALLS:-0}" ] && exit 1
      exit 0
    fi
    if [[ "$*" == *"--connect-to www.antcat.org:443:web:443"* ]]; then
      # The probe through nginx after a recreate. FAKE_NGINX_DOWN_CALLS: the first N get no answer.
      n=$(( $(cat "$DOCKER_LOG.nginx" 2> /dev/null || echo 0) + 1 )); echo "$n" > "$DOCKER_LOG.nginx"
      if [ "$n" -le "${FAKE_NGINX_DOWN_CALLS:-0}" ]; then printf 000; exit 7; fi
      printf '%s' "${FAKE_NGINX_HTTP:-200}"; exit 0
    fi
    if [[ "$*" == *curl* ]] && [ -n "${FAKE_DOWN_UNTIL_MIGRATED:-}" ] && ! grep -q db:migrate "$DOCKER_LOG"; then
      printf 000; exit 7
    fi
    if [[ "$*" == *curl* && "$*" == *http_code* ]]; then
      # FAKE_DOWN_CALLS: the first N health requests find nothing listening (curl prints 000, exits 7).
      n=$(( $(cat "$DOCKER_LOG.down" 2> /dev/null || echo 0) + 1 )); echo "$n" > "$DOCKER_LOG.down"
      if [ "$n" -le "${FAKE_DOWN_CALLS:-0}" ]; then printf 000; exit 7; fi
      echo "${FAKE_HTTP:-200}"; exit 0
    fi
    if [[ "$*" == *curl* ]]; then
      # FAKE_FOOTER_NONE: the app could not read its commit, the footer shows the version only.
      if [ -n "${FAKE_FOOTER_NONE:-}" ]; then echo "<footer>Version 4.0.0</footer>"; exit 0; fi
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
  unset ANTCAT_NGINX_WAIT
  unset FAKE_HTTP FAKE_MIGRATE_RC FAKE_RESTART_RC FAKE_BUILD_RC FAKE_DOWN_CALLS FAKE_GEMS_MISSING_CALLS FAKE_DOWN_UNTIL_MIGRATED FAKE_NGINX_TEST_RC FAKE_NGINX_RECREATE_RC FAKE_NGINX_DOWN_CALLS FAKE_NGINX_RELOAD_RC FAKE_NGINX_HTTP
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
check "health check asks the API front door on the local port" docker_called "http://127.0.0.1:8080/v1\\( \\|$\\)"
check "health check asks a taxon's catalog page" docker_called "http://127.0.0.1:8080/catalog/429011"
check "health check never asks a data path the API keys limit" not docker_called "8080/v1/"
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

setup "a plain deploy does not replace a tested branch without --yes"
git -C "$WORK" checkout -q -b feature
echo x > "$WORK/feature.txt"; git -C "$WORK" add -A; git -C "$WORK" commit -qm "F: feature"
git -C "$WORK" push -q origin feature
F="$(git -C "$WORK" rev-parse HEAD)"
run --ref feature
check "the feature branch is deployed" head_is "$F"
STARTS="$(grep -c "deploy start" "$ANTCAT_DEPLOY_LOG")"
run --dry-run
check "dry run exits 0" [ "$RC" -eq 0 ]
check "dry run names the branch" out_has "is not on master (it is on: feature)"
check "dry run says a real deploy would ask for --yes" out_has "a real deploy would stop here and ask for --yes"
run
check "refuses without --yes" [ "$RC" -ne 0 ]
check "says how to go on" out_has "run again with --yes"
check "HEAD is still the feature commit" head_is "$F"
check "the rollback commit is not overwritten" [ "$(tr -d '[:space:]' < "$ANTCAT_ROLLBACK_FILE")" = "$A" ]
check "no new deploy start in the log" [ "$(grep -c "deploy start" "$ANTCAT_DEPLOY_LOG")" = "$STARTS" ]
run --yes
check "deploys master with --yes" head_is "$A"
teardown

setup "a newer commit of the tested branch needs no --yes"
git -C "$WORK" checkout -q -b feature
echo x > "$WORK/feature.txt"; git -C "$WORK" add -A; git -C "$WORK" commit -qm "F: feature"
git -C "$WORK" push -q origin feature
run --ref feature
check "the first feature commit is deployed" [ "$RC" -eq 0 ]
echo y > "$WORK/feature.txt"; git -C "$WORK" commit -qam "F2: feature"
git -C "$WORK" push -q origin feature
F2="$(git -C "$WORK" rev-parse HEAD)"
run --ref feature
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the newer feature commit" head_is "$F2"
check "no --yes asked" not out_has "run again with --yes"
teardown

setup "a tested branch deleted on GitHub: still asks for --yes, with a message"
git -C "$WORK" checkout -q -b feature
echo x > "$WORK/feature.txt"; git -C "$WORK" add -A; git -C "$WORK" commit -qm "F: feature"
git -C "$WORK" push -q origin feature
F="$(git -C "$WORK" rev-parse HEAD)"
run --ref feature
check "the feature branch is deployed" head_is "$F"
git -C "$WORK" push -q origin --delete feature
git -C "$SERVER" fetch -q --prune origin
run --dry-run
check "dry run exits 0" [ "$RC" -eq 0 ]
check "says it is not on master, no branch named" out_has "is not on master: probably a branch being tested here"
run
check "refuses without --yes" [ "$RC" -ne 0 ]
check "says how to go on" out_has "run again with --yes"
check "HEAD is still the feature commit" head_is "$F"
run --yes
check "deploys master with --yes" head_is "$A"
teardown

setup "runs the deploy script of origin/master when the checkout's copy differs"
mkdir -p "$WORK/script"
# shellcheck disable=SC2016  # the stub expands them when it runs
printf '#!/usr/bin/env bash\necho "MASTER SCRIPT $* dir=$ANTCAT_DIR from=$ANTCAT_DEPLOY_FROM_MASTER"\n' > "$WORK/script/deploy"
git -C "$WORK" add -A; git -C "$WORK" commit -qm "M: master's deploy script"; git -C "$WORK" push -q origin master
run --dry-run --timeout 5
check "exits 0" [ "$RC" -eq 0 ]
check "says it runs master's script" out_has "running the deploy script of origin/master"
check "master's script ran with the same options" out_has "MASTER SCRIPT --dry-run --timeout 5 dir=$SERVER from=1"
check "did not move HEAD" head_is "$A"
teardown

setup "runs its own copy when it is master's"
mkdir -p "$WORK/script"
cp "$DEPLOY" "$WORK/script/deploy"
git -C "$WORK" add -A; git -C "$WORK" commit -qm "M: master's deploy script = this one"; git -C "$WORK" push -q origin master
run --dry-run
check "exits 0" [ "$RC" -eq 0 ]
check "does not say it runs another script" not out_has "running the deploy script of origin/master"
check "the dry run ran" out_has "dry run: nothing changed."
teardown

setup "says when origin/master has no deploy script, and goes on"
B="$(push_change app/models/taxon.rb "B: model change")"
run --dry-run
check "exits 0" [ "$RC" -eq 0 ]
check "warns" out_has "origin/master has no script/deploy; running this copy"
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

setup "migrations wait for the gems, not for Puma"
B="$(push_change db/migrate/20261109000000_add_api_keys.rb "B: add api keys")"
export FAKE_GEMS_MISSING_CALLS=3 FAKE_DOWN_UNTIL_MIGRATED=1
run
check "exits 0" [ "$RC" -eq 0 ]
check "checked the gems until they were there" [ "$(grep -c 'bundle check' "$DOCKER_LOG")" -eq 4 ]
check "migrated without any health request first" \
  [ "$(grep -n -m1 db:migrate "$DOCKER_LOG" | cut -d: -f1)" -lt "$(grep -n -m1 curl "$DOCKER_LOG" | cut -d: -f1)" ]
check "no error reported while waiting" not out_has "UNEXPECTED ERROR"
check "no FAILED line in the deploy log" not grep -q FAILED "$ANTCAT_DEPLOY_LOG"
teardown

setup "health check waits while nothing listens"
B="$(push_change app/models/taxon.rb "B: model change")"
export FAKE_DOWN_CALLS=3
run
check "exits 0" [ "$RC" -eq 0 ]
check "no error reported while waiting" not out_has "UNEXPECTED ERROR"
check "no FAILED line in the deploy log" not grep -q FAILED "$ANTCAT_DEPLOY_LOG"
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

setup "nginx config change: tested, then the nginx container is recreated (a reload reads the old file)"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "plan says nginx is recreated" out_has "nginx config .*YES: tested, then the nginx container"
check "tested the new config in a throwaway container" docker_called "compose .* run --rm --no-deps -T web nginx -t"
check "recreated only the nginx container" docker_called "compose .*up -d --force-recreate --no-deps web"
check "did not rely on a reload" not docker_called "nginx -s reload"
check "asked for a page through nginx, with the site's own name" docker_called "exec antcat-app curl .*--connect-to www.antcat.org:443:web:443 https://www.antcat.org/v1"
check "says nginx serves the site with the new config" out_has "nginx serves the site with this config (/v1 through nginx: 200)"
check "server log line records it" out_has "nginx: recreated with the checked-out config)"
check "no nginx warning" not out_has "WARNING (nginx)"
teardown

setup "nginx config change that fails its test: not loaded, nginx untouched, warning printed last"
B="$(push_change dockerized_app/nginx/default.conf "B: broken nginx config")"
export FAKE_NGINX_TEST_RC=1
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "deployed the new code" head_is "$B"
check "did not recreate nginx" not docker_called "force-recreate"
check "did not reload nginx" not docker_called "nginx -s reload"
check "warns that the config was not loaded" out_has "WARNING (nginx): the nginx config test FAILED or could not run"
check "the warning comes after the summary" [ "$(grep -n 'WARNING (nginx)' <<< "$OUT" | cut -d: -f1)" -gt "$(grep -n 'Server log entry' <<< "$OUT" | cut -d: -f1)" ]
check "shows the test output" out_has "nginx: fake config test"
check "says a restart of nginx would take the site down" out_has "nginx will NOT start with it"
check "says what to do" out_has "Fix the config and deploy again, or run script/deploy --rollback now"
check "server log line records it" out_has "nginx: PROBLEM, see the deploy output)"
check "written to the deploy log" grep -q "nginx WARNING" "$ANTCAT_DEPLOY_LOG"
teardown

setup "nginx container cannot be recreated: warning, deploy still reported"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
export FAKE_NGINX_RECREATE_RC=1
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "warns" out_has "WARNING (nginx): recreating the nginx container failed"
teardown

setup "nginx recreated but not answering: warning after the wait"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
export FAKE_NGINX_DOWN_CALLS=1000 ANTCAT_NGINX_WAIT=2
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "warns that nginx does not serve the site" out_has "WARNING (nginx): the nginx container was recreated but does not serve the site (/v1 through nginx: 000 after [2-9] s, 200 expected)"
check "does not claim the site is served" not out_has "nginx serves the site"
check "server log line records it" out_has "nginx: PROBLEM, see the deploy output)"
teardown

setup "nginx answers after a few probes: no warning"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
export FAKE_NGINX_DOWN_CALLS=2
run
check "exits 0" [ "$RC" -eq 0 ]
check "says nginx serves the site" out_has "nginx serves the site with this config"
check "no nginx warning" not out_has "WARNING (nginx)"
teardown

setup "nginx recreated but answering 502 (cannot reach the app): warning, not success"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
export FAKE_NGINX_HTTP=502 ANTCAT_NGINX_WAIT=2
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "warns with the status" out_has "WARNING (nginx): the nginx container was recreated but does not serve the site (/v1 through nginx: 502"
check "does not claim the site is served" not out_has "nginx serves the site"
teardown

setup "Dockerfile change with an nginx config that fails its test: the running nginx is still reloaded"
push_change dockerized_app/Dockerfile "B1: new Ruby" > /dev/null
B="$(push_change dockerized_app/nginx/default.conf "B2: broken nginx config")"
export FAKE_NGINX_TEST_RC=1
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "recreated the app container" docker_called "compose .*up -d --no-deps app"
check "did not recreate nginx" not docker_called "force-recreate"
check "reloaded the running nginx (new app container address)" docker_called "nginx -s reload"
check "warns that the config was not loaded" out_has "WARNING (nginx): the nginx config test FAILED or could not run"
teardown

setup "Dockerfile change with a good nginx config: recreated, no extra reload"
push_change dockerized_app/Dockerfile "B1: new Ruby" > /dev/null
B="$(push_change dockerized_app/nginx/default.conf "B2: nginx header")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "recreated nginx" docker_called "compose .*up -d --force-recreate --no-deps web"
check "no reload needed" not docker_called "nginx -s reload"
teardown

setup "nginx reload fails after a Dockerfile change: warning with the command"
B="$(push_change dockerized_app/Dockerfile "B: new Ruby")"
export FAKE_NGINX_RELOAD_RC=1
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "warns with the reload command" out_has "WARNING (nginx): nginx reload failed .*exec -T web nginx -s reload"
teardown

setup "rollback across an nginx config change recreates the nginx container again"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
run
: > "$DOCKER_LOG"
run --rollback
check "exits 0" [ "$RC" -eq 0 ]
check "back on A" head_is "$A"
check "recreated the nginx container" docker_called "compose .*up -d --force-recreate --no-deps web"
check "server log line records nginx" out_has "with script/deploy --rollback (nginx: recreated with the checked-out config)."
teardown

setup "nginx answering with a redirect, not the page: warning, not success"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx redirect")"
export FAKE_NGINX_HTTP=301 ANTCAT_NGINX_WAIT=2
run
check "the deploy itself succeeds" [ "$RC" -eq 0 ]
check "warns with the status" out_has "WARNING (nginx): .*through nginx: 301 after [2-9] s, 200 expected"
teardown

setup "rollback to an nginx config that fails its test: warning after the rollback summary"
B="$(push_change dockerized_app/nginx/default.conf "B: nginx header")"
run
: > "$DOCKER_LOG"
export FAKE_NGINX_TEST_RC=1
run --rollback
check "the rollback itself succeeds" [ "$RC" -eq 0 ]
check "back on A" head_is "$A"
check "did not recreate nginx" not docker_called "force-recreate"
check "warns" out_has "WARNING (nginx): the nginx config test FAILED or could not run"
check "the warning comes after the summary" [ "$(grep -n 'WARNING (nginx)' <<< "$OUT" | cut -d: -f1)" -gt "$(grep -n 'Server log entry' <<< "$OUT" | cut -d: -f1)" ]
check "server log line records it" out_has "(nginx: PROBLEM, see the deploy output)."
teardown

setup "no nginx change: the nginx container is left alone"
B="$(push_change app/models/taxon.rb "B: model change")"
run
check "exits 0" [ "$RC" -eq 0 ]
check "no nginx test" not docker_called "web nginx -t"
check "no recreate" not docker_called "force-recreate"
check "no reload" not docker_called "nginx -s reload"
teardown

setup "a root shell with umask 077 does not make the checkout unreadable for the app"
B="$(push_change app/models/taxon.rb "B: model change")"
OLD_UMASK="$(umask)"; umask 077; run; umask "$OLD_UMASK"
check "exits 0" [ "$RC" -eq 0 ]
check "HEAD is the new commit" head_is "$B"
check ".git/HEAD readable by others" [ "$(( $(stat -c '%a' "$SERVER/.git/HEAD") % 10 ))" -ge 4 ]
check "the changed file is readable by others" [ "$(( $(stat -c '%a' "$SERVER/app/models/taxon.rb") % 10 ))" -ge 4 ]
teardown

setup "a footer without any commit says the app could not read it"
B="$(push_change app/models/taxon.rb "B: model change")"
export FAKE_FOOTER_NONE=1
run --timeout 3
check "exits non-zero" [ "$RC" -ne 0 ]
check "says the footer shows no commit" out_has "the footer shows no commit: the app could not read it (.git/HEAD is "
teardown

echo
echo "$TESTS tests, $FAILS failed checks"
[ "$FAILS" -eq 0 ]
