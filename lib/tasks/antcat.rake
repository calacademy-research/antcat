# frozen_string_literal: true

desc "List interesting tasks and commands (AntCat, AntWeb, Solr, etc.)"
task :antcat do
  puts "### Rake tasks:"
  prefixes = %w[
    antcat:
    antweb
    db:import_latest
    dev
    factory_bot
    sunspot
    zeitwerk
  ]
  tasks = `rake -T`.lines
  puts tasks.grep(/^rake #{Regexp.union(prefixes)}/)
  puts

  puts <<~STR
    ### Other commands:
    cucumber
    haml-lint
    rspec
    rubocop

  STR

  puts <<~STR
    ### script subdir:
    /data/antcat/current/script/solr/restart_and_reindex production
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

  puts <<~STR
    ### ENV variables (for specific commands):
    PRINT_FEATURE_NAME=y   cucumber
    PROFILE_EXAMPLES=y     rspec
    GUARD=all              guard
    GUARD=spec             guard
    GUARD=rubocop          guard
  STR
end

task ac: :antcat
