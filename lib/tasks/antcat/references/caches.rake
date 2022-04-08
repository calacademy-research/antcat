# frozen_string_literal: true

# Formatted references and keys are cached in the database. Use this to regenerate or invalidate them.

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

    desc 'Check all reference content caches'
    task check_content_caches: :environment do
      with_plain_text_cache = Reference.where.not(plain_text_cache: nil)
      with_expanded_reference_cache = Reference.where.not(expanded_reference_cache: nil)

      progress = ProgressBar.create(
        total: with_plain_text_cache.count + with_expanded_reference_cache.count,
        format: "%a %e %P% Processed: %c from %C",
        throttle_rate: 0.5
      )

      with_plain_text_cache.find_each do |reference|
        progress.increment

        plain_text = CGI.unescapeHTML(References::Formatted::PlainText.new(reference).call)
        plain_text_cache = CGI.unescapeHTML(reference.plain_text_cache)

        unless plain_text_cache == plain_text
          puts "plain_text_cache not in sync for Reference.find(#{reference.id})".red
          puts "  plain_text_cache: #{plain_text_cache}"
          puts "  plain_text: #{plain_text}"
        end
      end

      with_expanded_reference_cache.find_each do |reference|
        progress.increment

        expanded_reference = CGI.unescapeHTML(References::Formatted::Expanded.new(reference).call)
        expanded_reference_cache = CGI.unescapeHTML(reference.expanded_reference_cache)

        unless expanded_reference_cache == expanded_reference
          puts "expanded_reference_cache not in sync for Reference.find(#{reference.id})".red
          puts "  expanded_reference_cache: #{expanded_reference_cache}"
          puts "  expanded_reference: #{expanded_reference}"
        end
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

        unless reference.key_with_suffixed_year_cache == key_with_suffixed_year
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

        unless reference.key_with_suffixed_year_cache == key_with_suffixed_year
          puts "key_with_suffixed_year_cache not in sync for Reference.find(#{reference.id})".red
          puts "  key_with_suffixed_year_cache: #{reference.key_with_suffixed_year_cache}"
          puts "  key_with_suffixed_year: #{key_with_suffixed_year}"
        end
      end
    end
  end
end
