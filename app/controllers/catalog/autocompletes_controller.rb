# frozen_string_literal: true

module Catalog
  class AutocompletesController < ApplicationController
    NUM_RESULTS = 10

    def show
      render json: serialized_taxa
    end

    private

      def serialized_taxa
        taxa.map do |taxon|
          {
            id: taxon.id,
            plaintext_name: taxon.name_cache,
            name_with_fossil: taxon.name_with_fossil,
            author_citation: taxon.author_citation,
            css_classes: CatalogFormatter.taxon_disco_mode_css(taxon),
            url: "/catalog/#{taxon.id}"
          }
        end
      end

      def taxa
        Autocomplete::TaxaQuery[search_query, rank: rank, per_page: NUM_RESULTS]
      end

      def search_query
        params[:q] || params[:qq] || ''
      end

      def rank
        params[:rank]
      end
  end
end
