# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json do
          render json: serialized_protonyms
        end
      end
    end

    private

      def serialized_protonyms
        search_query = params[:qq] || ''
        Autocomplete::ProtonymsQuery[search_query]
      end
  end
end
