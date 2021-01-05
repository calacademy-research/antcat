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
          Autocomplete::TaxonSerializer.new(taxon).as_json
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
