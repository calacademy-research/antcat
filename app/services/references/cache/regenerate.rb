# frozen_string_literal: true

module References
  module Cache
    class Regenerate
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        invalidate
        regenerate
      end

      private

        attr_reader :reference

        def invalidate
          References::Cache::Invalidate[reference]
        end

        # NOTE: This depends on the formatter setting the caches, which is not
        # necessarily what we want in the long run.
        def regenerate
          formatter.plain_text
          formatter.expandable_reference
          formatter.expanded_reference
        end

        def formatter
          @formatter ||= CachedReferenceFormatter.new(reference)
        end
    end
  end
end
