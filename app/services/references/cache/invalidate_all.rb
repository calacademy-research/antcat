module References
  module Cache
    class InvalidateAll
      include Service

      def call
        puts "Invalidating all reference caches...".yellow

        Reference.update_all formatted_cache: nil, inline_citation_cache: nil

        puts "Invalidating all reference caches done.".green
      end
    end
  end
end
