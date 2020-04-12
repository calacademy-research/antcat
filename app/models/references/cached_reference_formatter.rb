# frozen_string_literal: true

# TODO: Do not cache in database.

module References
  class CachedReferenceFormatter
    attr_private_initialize :reference

    def plain_text
      cached_render References::Formatted::PlainText, :plain_text_cache
    end

    def expanded_reference
      cached_render References::Formatted::Expanded, :expanded_reference_cache
    end

    def expandable_reference
      cached_render References::Formatted::Expandable, :expandable_reference_cache
    end

    private

      def cached_render formatter_class, column
        return formatter_class.new(reference).call if ENV['NO_REF_CACHE']
        return reference.public_send(column).html_safe if reference.public_send(column)

        References::Cache::Set[reference, formatter_class.new(reference).call, column]
      end
  end
end
