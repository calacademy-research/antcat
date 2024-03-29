# frozen_string_literal: true

module References
  module Cache
    class Invalidate
      include Service

      def initialize references
        @references = Array.wrap(references)
      end

      def call
        references.each do |reference|
          invalidate_caches reference
        end
      end

      private

        attr_reader :references

        def invalidate_caches reference
          return if reference.new_record?

          reference.update_columns(
            plain_text_cache: nil,
            expanded_reference_cache: nil
          )

          References::Cache::Invalidate[reference.nested_references]
        end
    end
  end
end
