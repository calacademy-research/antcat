# rubocop:disable Rails/Output
module References
  module Cache
    class InvalidateAll
      include Service

      def call
        puts "Invalidating all reference caches...".yellow

        Reference.update_all plain_text_cache: nil, expandable_reference_cache: nil

        puts "Invalidating all reference caches done.".green
      end
    end
  end
end
# rubocop:enable Rails/Output
