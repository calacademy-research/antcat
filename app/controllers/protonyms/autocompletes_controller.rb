# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_protonyms
    end

    private

      def serialized_protonyms
        search_query = params[:qq] || ''
        Autocomplete::ProtonymsQuery[search_query]
      end
  end
end
