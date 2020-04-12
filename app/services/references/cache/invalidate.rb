# frozen_string_literal: true

module References
  module Cache
    class Invalidate
      include Service

      attr_private_initialize :reference

      def call
        return if reference.new_record?

        # rubocop:disable Rails/SkipsModelValidations
        reference.update_columns(
          plain_text_cache: nil,
          expandable_reference_cache: nil,
          expanded_reference_cache: nil
        )
        # rubocop:enable Rails/SkipsModelValidations
        reference.nestees.each do |nestee|
          References::Cache::Invalidate[nestee]
        end
      end
    end
  end
end
