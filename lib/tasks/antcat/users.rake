# frozen_string_literal: true

namespace :antcat do
  namespace :users do
    desc "Remove password hashes, tokens and sign-in data from existing User versions (DRY_RUN=n to write)"
    task scrub_sensitive_version_data: [:environment] do
      dry_run = ENV['DRY_RUN'] != 'n'

      puts(dry_run ? "Dry run, no changes will be saved (use DRY_RUN=n to write)." : "Writing changes.")
      counts = Users::ScrubSensitiveVersionData[dry_run: dry_run]

      puts "User versions checked: #{counts[:checked]}"
      puts "User versions with sensitive keys: #{counts[:affected]}"
      counts[:removed_keys].sort.each do |key, count|
        puts "  #{key}: #{count}"
      end
    end
  end
end
