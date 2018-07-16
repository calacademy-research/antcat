module References
  module Cache
    class Invalidate
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        return if reference.new_record?

        reference.update_column :formatted_cache, nil
        reference.update_column :inline_citation_cache, nil
        reference.nestees.each &:invalidate_caches
      end

      private

        attr_reader :reference
    end
  end
end
