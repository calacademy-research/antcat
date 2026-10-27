# frozen_string_literal: true

module Authors
  class AutocompletesController < ApplicationController
    MAX_RESULTS = 50

    def show
      render json: serialized_author_names
    end

    private

      def serialized_author_names
        author_names.map do |author_name|
          {
            label: author_name.name,
            author_id: author_name.author_id,
            url: "/authors/#{author_name.author_id}"
          }
        end
      end

      def author_names
        Autocomplete::AuthorNamesQuery[params[:term]].limit(limit)
      end

      def limit
        (Integer(params[:limit].to_s, exception: false) || MAX_RESULTS).clamp(1, MAX_RESULTS)
      end
  end
end
