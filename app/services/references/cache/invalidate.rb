# frozen_string_literal: true

module References
  module Cache
    class Invalidate
      include Service

      attr_private_initialize :reference

      # rubocop:disable Rails/SkipsModelValidations
      def call
        return if reference.new_record?

        reference.update_columns(
          plain_text_cache: nil,
          expandable_reference_cache: nil,
          expanded_reference_cache: nil
        )
        reference.nestees.each do |nestee|
          References::Cache::Invalidate[nestee]
        end
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
