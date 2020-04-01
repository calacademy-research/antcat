# frozen_string_literal: true

module References
  module Cache
    class Set
      include Service

      attr_private_initialize :reference, :value, :field

      def call
        return value unless reference.persisted?

        # Skip if cache is already up to date.
        return value if reference.public_send(field) == value

        reference.update_column(field, value) # rubocop:disable Rails/SkipsModelValidations
        value
      end
    end
  end
end
