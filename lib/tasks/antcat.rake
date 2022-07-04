# frozen_string_literal: true

desc "List interesting tasks and commands (AntCat, AntWeb, Solr, etc.)"
task :antcat do
  puts "### Various commands".green
  puts <<~STR
    ./bin/dev
    ./bin/webpack-dev-server
    brakeman
    bundle audit check --update
    cucumber
      PRINT_FEATURE_NAME=y   cucumber
    cat docker_dev/README.md
    guard
      GUARD=all              guard
      GUARD=spec             guard
      GUARD=rubocop          guard
    haml-lint
    rspec
      PROFILE_EXAMPLES=y     rspec
      rspec --tag=relational_hi
      rspec --only-failures
      rspec --next-failure
    rubocop

  STR

  puts "### ENV variables (for `rails c` and similar)".green
  puts <<~STR
    DEV_MONKEY_PATCHES=y   rails c       # Enable dev monkey patches in other envs.
    DLL=y                  rails s       # Debug Log Level.
    NO_REF_CACHE=y         rails s       # Don't show cached `Reference`s (always render).
    SIMULATE_PRODUCTION=y  rails s       # Ctrl+F for more info.
    SIMULATE_STAGING=y     rails s

  STR

  puts "## Interesting rake tasks".green
  rake_tasks = `rake -T`.lines

  puts "### Default/vendored tasks".green
  prefixes = [
    'assets:clean',
    'assets:clobber',
    'assets:precompile',
    'sunspot',
    'zeitwerk'
  ]
  puts rake_tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts "### Custom tasks".green
  prefixes = [
    'antcat:',
    'antweb',
    'db:import_latest',
    'factory_bot',
    'logged',
    'seed:',
    /test[^:]/,
    'yamllint'
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
