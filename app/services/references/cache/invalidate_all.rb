# Run in terminal: rake antcat:reference_caches:invalidate
# To run in Rails console: References::Cache::InvalidateAll[]

module References
  module Cache
    class InvalidateAll
      include Service

      # rubocop:disable Rails/SkipsModelValidations
      def call
        Reference.update_all plain_text_cache: nil, expandable_reference_cache: nil,
          expanded_reference_cache: nil
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
