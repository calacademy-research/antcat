# frozen_string_literal: true

desc "List interesting tasks and commands (AntCat, AntWeb, Solr, etc.)"
task :antcat do
  puts "### Rake tasks:"
  prefixes = %w[
    antcat:
    antweb
    db:import_latest
    factory_bot
    seed:
    sunspot
    yamllint
    zeitwerk
  ]
  tasks = `rake -T`.lines
  puts tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts <<~STR
    ### Other commands:
    brakeman
    bundle audit check --update
    cucumber
      PRINT_FEATURE_NAME=y   cucumber
    guard
      GUARD=all              guard
      GUARD=spec             guard
      GUARD=rubocop          guard
    haml-lint
    rspec
      PROFILE_EXAMPLES=y     rspec
      rspec --tag=relational_hi
    rubocop

  STR

  puts <<~STR
    ### script subdir:
    ./script/solr/restart_and_reindex                          # Any env, also works on EngineYard.
    /data/antcat/current/script/solr/restart_and_reindex       # Absolute path on EngineYard (because lazy).
    script/db_dump/README.md

  STR

  puts <<~STR
    ### ENV variables (for `rails c` and similar):
    DEV_MONKEY_PATCHES=y   rails c       # Enable dev monkey patches in other envs.
    DLL=y                  rails s       # Debug Log Level.
    NO_REF_CACHE=y         rails s       # Don't show cached `Reference`s (always render).
    SIMULATE_PRODUCTION=y  rails s       # Ctrl+F for more info.
    SIMULATE_STAGING=y     rails s
  STR
end
task ac: :antcat # Shortcut.
