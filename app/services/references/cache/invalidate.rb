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

          # rubocop:disable Rails/SkipsModelValidations
          reference.update_columns(
            plain_text_cache: nil,
            expandable_reference_cache: nil,
            expanded_reference_cache: nil
          )
          # rubocop:enable Rails/SkipsModelValidations

          References::Cache::Invalidate[reference.nestees]
        end
    end
  end
end
