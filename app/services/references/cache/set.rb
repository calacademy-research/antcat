module References
  module Cache
    class Set
      include Service

      def initialize reference, value, field
        @reference = reference
        @value = value
        @field = field
      end

      def call
        return value unless reference.persisted?

        # Skip if cache is already up to date.
        return value if reference.send(field) == value

        reference.update_column field, value
        value
      end

      private

        attr_reader :reference, :value, :field
    end
  end
end
