# frozen_string_literal: true

# Formatted references are cached in the database. Use this to regenerate or invalidate them.

namespace :antcat do
  namespace :reference_caches do
    desc 'Invalidates all reference caches'
    task invalidate: :environment do
      # rubocop:disable Rails/SkipsModelValidations
      Reference.update_all(
        plain_text_cache: nil,
        expandable_reference_cache: nil,
        expanded_reference_cache: nil
      )
      # rubocop:enable Rails/SkipsModelValidations
    end

    desc 'Regenerate all reference caches'
    task regenerate: :environment do
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
          # rubocop:disable Rails/SkipsModelValidations
          reference.update_columns key_with_suffixed_year_cache: key_with_suffixed_year
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
