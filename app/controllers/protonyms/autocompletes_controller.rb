# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_protonyms
    end

    private

      def serialized_protonyms
        protonyms.map do |protonym|
          {
            id: protonym.id,
            name_with_fossil: protonym.decorate.name_with_fossil,
            author_citation: protonym.authorship.reference.keey_without_letters_in_year
          }
        end
      end

      def protonyms
        search_query = params[:qq] || ''
        Autocomplete::ProtonymsQuery[search_query]
      end
  end
end
