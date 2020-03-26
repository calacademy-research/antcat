# frozen_string_literal: true

module Catalog
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:q] || params[:qq] || ''
      rank = params[:rank]

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteTaxa[search_query, rank: rank]
        end
      end
    end
  end
end
