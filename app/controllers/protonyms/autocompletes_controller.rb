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
            plaintext_name: protonym.name.name,
            name_with_fossil: protonym.decorate.name_with_fossil,
            author_citation: protonym.author_citation,
            url: "/protonyms/#{protonym.id}"
          }
        end
      end

      def protonyms
        Autocomplete::ProtonymsQuery[search_query].
          joins(:name).includes(:name, { authorship: { reference: :author_names } }).
          limit(NUM_RESULTS)
      end

      def search_query
        params[:q] || params[:qq]
      end
  end
end
