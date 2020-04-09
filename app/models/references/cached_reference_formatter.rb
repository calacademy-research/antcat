# frozen_string_literal: true

# TODO: Do not cache in database.

module References
  class CachedReferenceFormatter
    attr_private_initialize :reference

    def plain_text
      return References::Formatted::PlainText[reference] if ENV['NO_REF_CACHE']
      return plain_text_cache.html_safe if plain_text_cache

      set_cache References::Formatted::PlainText[reference], :plain_text_cache
    end

    def expanded_reference
      return References::Formatted::Expanded[reference] if ENV['NO_REF_CACHE']
      return expanded_reference_cache.html_safe if expanded_reference_cache

      set_cache References::Formatted::Expanded[reference], :expanded_reference_cache
    end

    def expandable_reference
      return References::Formatted::Expandable[reference] if ENV['NO_REF_CACHE']
      return expandable_reference_cache.html_safe if expandable_reference_cache

      set_cache References::Formatted::Expandable[reference], :expandable_reference_cache
    end

    private

      delegate :plain_text_cache, :expandable_reference_cache, :expanded_reference_cache,
        to: :reference, private: true

      def set_cache value, column
        References::Cache::Set[reference, value, column]
      end
  end
end
