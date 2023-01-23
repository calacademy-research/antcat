# frozen_string_literal: true

module Catalog
  class AutocompletesController < ApplicationController
    NUM_RESULTS = 10

    def show
      respond_to do |format|
        format.json { render json: serialized_taxa }
        format.html do
          @taxa = taxa
          @protonyms = protonyms
          @pickable_type = params[:pickable_type]

          render layout: false
        end
      end
    end

    private

      def serialized_taxa
        taxa.map do |taxon|
          Autocomplete::TaxonSerializer.new(taxon).as_json(include_protonym: include_protonym?)
        end
      end

      def taxa
        Autocomplete::TaxaQuery[search_query, rank: rank, per_page: per_page]
      end

      def protonyms
        Autocomplete::ProtonymsQuery[search_query, per_page: per_page]
      end

      def search_query
        params[:q] || params[:qq] || ''
      end

      def rank
        params[:rank]
      end

      def include_protonym?
        params[:include_protonym].present?
      end

      def per_page
        (Integer(params[:per_page], exception: false) || NUM_RESULTS).clamp(1, NUM_RESULTS)
      end
  end
end
