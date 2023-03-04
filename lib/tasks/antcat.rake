# frozen_string_literal: true

desc "List interesting tasks and commands (AntCat, AntWeb, Solr, etc.)"
task :antcat do
  puts "### Dev commands".green
  puts <<~STR
    ./bin/dev
    ./bin/webpack-dev-server
    brakeman
    bundle audit check --update
    cat docker_dev/README.md
    guard                      # Or: GUARD=all guard; GUARD=spec guard; GUARD=rubocop guard
    haml-lint
    rspec                      # Or: PROFILE_EXAMPLES=y rspec; rspec --tag=relational_hi
                               # Or: rspec --only-failures; rspec --next-failure
    rubocop

  STR

  puts "### ENV variables (for `rails c` and similar)".green
  puts <<~STR
    DEV_MONKEY_PATCHES=y   rails c       # Enable dev monkey patches in other envs.
    DLL=y                  rails s       # Debug Log Level.
    NO_REF_CACHE=y         rails s       # Don't show cached `Reference`s (always render).
    SIMULATE_STAGING=y     rails s       # Or: SIMULATE_PRODUCTION=y rails s; Ctrl+F for more info.

  STR

  puts "## Interesting rake tasks".green
  rake_tasks = `rake -T`.lines

  puts "### Default/vendored".blue
  prefixes = [
    'assets:clean',
    'assets:clobber',
    'assets:precompile',
    'sunspot',
    'zeitwerk'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Data export".blue
  prefixes = [
    'antweb:export'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Data consistency".blue
  prefixes = [
    'antcat:invalid_records',
    'antcat:references:check_content_caches',
    'antcat:references:check_key_caches',
    'antcat:references:solr_search_test',
    'antcat:tooltips:missing',
    'antcat:tooltips:unused'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Invalidate/regenerate caches".blue
  prefixes = [
    'antcat:references:invalidate_content_caches',
    'antcat:references:regenerate_content_caches',
    'antcat:references:regenerate_key_caches'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Testing/linting/coverage".blue
  prefixes = [
    'antcat:coverage',
    'antcat:rubycritic',
    'factory_bot:lint',
    'test ',
    'lint'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Dev data".blue
  prefixes = [
    'db:import_latest',
    'db:import_latest_quick',
    'seed:catalog',
    'seed:relational_history_items'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Misc.".blue
  prefixes = [
    'logged'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### script subdir".green
  puts <<~STR
    tree script/
    ./script/solr/restart_and_reindex                          # Any env, also works on EngineYard.
    /data/antcat/current/script/solr/restart_and_reindex       # As above, but absolute path on EngineYard.

  STR
end
task ac: :antcat # Shortcut.
