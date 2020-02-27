module References
  module Cache
    class Invalidate
      include Service

      def initialize reference
        @reference = reference
      end

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

      private

        attr_reader :reference
    end
  end
end
