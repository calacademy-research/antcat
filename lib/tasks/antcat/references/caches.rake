# frozen_string_literal: true

# Formatted references are cached in the database. Use this to regenerate or invalidate them.

namespace :antcat do
  namespace :references do
    desc 'Invalidates all reference content caches'
    task invalidate_content_caches: :environment do
      Reference.update_all(
        plain_text_cache: nil,
        expanded_reference_cache: nil
      )
    end

    desc 'Regenerate all reference content caches'
    task regenerate_content_caches: :environment do
      progress = ProgressBar.create(
        total: Reference.count,
        format: "%a %e %P% Processed: %c from %C",
        throttle_rate: 0.5
      )

      Reference.find_each do |reference|
        progress.increment
        References::Cache::Regenerate[reference]
      end
    end

    desc 'Regenerate all reference key caches'
    task regenerate_key_caches: :environment do
      progress = ProgressBar.create(
        total: Reference.count,
        format: "%a %e %P% Processed: %c from %C",
        throttle_rate: 0.5
      )

      Reference.find_each do |reference|
        progress.increment
        key_with_suffixed_year = reference.key_with_suffixed_year

        if reference.key_with_suffixed_year_cache != key_with_suffixed_year
          reference.update_columns(key_with_suffixed_year_cache: key_with_suffixed_year)
        end
      end
    end

    desc 'Check all reference key caches'
    task check_key_caches: :environment do
      progress = ProgressBar.create(
        total: Reference.count,
        format: "%a %e %P% Processed: %c from %C",
        throttle_rate: 0.5
      )

      Reference.find_each do |reference|
        progress.increment
        key_with_suffixed_year = reference.key_with_suffixed_year

        if reference.key_with_suffixed_year_cache != key_with_suffixed_year
          puts "Keys not in sync for Reference##{reference.id}:".red
          puts "  #{reference.key_with_suffixed_year_cache}"
          puts "  #{key_with_suffixed_year}"
        end
      end
    end
  end
end
