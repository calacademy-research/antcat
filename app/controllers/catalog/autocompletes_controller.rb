# frozen_string_literal: true

module Catalog
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_taxa
    end

    private

      def serialized_taxa
        search_query = params[:q] || params[:qq] || ''
        Autocomplete::TaxaQuery[search_query, rank: params[:rank]]
      end
  end
end
