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

        reference.update_column :plain_text_cache, nil
        reference.update_column :expandable_reference_cache, nil
        reference.update_column :expanded_reference_cache, nil
        reference.nestees.each &:invalidate_caches
      end
      # rubocop:enable Rails/SkipsModelValidations

      private

        attr_reader :reference
    end
  end
end
