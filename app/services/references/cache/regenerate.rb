module References
  module Cache
    class Regenerate
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        set generate_formatted, :formatted_cache
        set generate_expandable_reference, :inline_citation_cache
      end

      private

        attr_reader :reference

        def set value, field
          References::Cache::Set[reference, value, field]
        end

        def generate_formatted
          reference.decorate.send(:generate_formatted)
        end

        def generate_expandable_reference
          reference.decorate.send(:generate_expandable_reference)
        end
    end
  end
end
