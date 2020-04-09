# frozen_string_literal: true

module References
  module Cache
    class Set
      include Service

      attr_private_initialize :reference, :value, :column

      def call
        return value unless reference.persisted?
        return value if already_up_to_date?

        reference.update_column(column, value) # rubocop:disable Rails/SkipsModelValidations
        value
      end

      private

        def already_up_to_date?
          reference.public_send(column) == value
        end
    end
  end
end
