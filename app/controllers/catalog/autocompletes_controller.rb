# frozen_string_literal: true

module Catalog
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_taxa
    end

    private

      def serialized_taxa
        taxa.map do |taxon|
          {
            id: taxon.id,
            name: taxon.name_cache,
            name_html: taxon.name_html_cache,
            name_with_fossil: taxon.name_with_fossil,
            author_citation: taxon.author_citation
          }
        end
      end

      def taxa
        search_query = params[:q] || params[:qq] || ''
        Autocomplete::TaxaQuery[search_query, rank: params[:rank]]
      end
  end
end
