module References
  module Cache
    class Regenerate
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        set generate_plain_text, :plain_text_cache
        set generate_expandable_reference, :expandable_reference_cache
      end

      private

        attr_reader :reference

        def set value, field
          References::Cache::Set[reference, value, field]
        end

        def generate_plain_text
          reference.decorate.send(:generate_plain_text)
        end

        def generate_expandable_reference
          reference.decorate.send(:generate_expandable_reference)
        end
    end
  end
end
