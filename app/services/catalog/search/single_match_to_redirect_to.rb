# frozen_string_literal: true

module Catalog
  module Search
    class SingleMatchToRedirectTo
      include Service

      def initialize search_query
        @search_query = search_query.dup.strip if search_query
      end

      def call
        return if search_query.blank?
        exact_name || exact_epithet
      end

      private

        attr_reader :search_query

        def exact_name
          matches = Taxon.where(name_cache: search_query)
          matches.first if matches.count == 1
        end

        def exact_epithet
          return unless search_query.split.size == 1

          matches = Taxon.joins(:name).where(names: { epithet: search_query })
          matches.first if matches.count == 1
        end
    end
  end
end
