# To run in console: References::Cache::InvalidateAll[]

module References
  module Cache
    class InvalidateAll
      include Service

      def call
        Reference.update_all plain_text_cache: nil, expandable_reference_cache: nil,
          expanded_reference_cache: nil
      end
    end
  end
end
