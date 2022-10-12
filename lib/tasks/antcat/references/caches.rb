# frozen_string_literal: true

module AntCat
  class Caches
    def invalidate_content_caches
      Reference.update_all(
        plain_text_cache: nil,
        expanded_reference_cache: nil
      )
    end

    def regenerate_content_caches
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

    def check_content_caches
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

    def regenerate_key_caches
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

    def check_key_caches
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
