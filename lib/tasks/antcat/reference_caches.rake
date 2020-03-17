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
  end
end
