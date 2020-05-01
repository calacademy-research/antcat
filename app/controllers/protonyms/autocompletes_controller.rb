# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    NUM_RESULTS = 10

    def show
      render json: serialized_protonyms
    end

    private

      def serialized_protonyms
        protonyms.map do |protonym|
          {
            id: protonym.id,
            name_with_fossil: protonym.decorate.name_with_fossil,
            author_citation: protonym.authorship.reference.keey_without_letters_in_year,
            url: "/protonyms/#{protonym.id}"
          }
        end
      end

      def protonyms
        Autocomplete::ProtonymsQuery[params[:qq]].limit(NUM_RESULTS)
      end
  end
end
