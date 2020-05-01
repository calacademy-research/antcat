# frozen_string_literal: true

module Authors
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_author_names
    end

    private

      def serialized_author_names
        if params[:with_ids] # TODO: Start using this instead of just names as strings.
          author_names.map do |author_name|
            {
              label: author_name.name,
              author_id: author_name.author_id,
              url: "/authors/#{author_name.author_id}"
            }
          end
        else
          author_names.map(&:name)
        end
      end

      def author_names
        Autocomplete::AuthorNamesQuery[params[:term]]
      end
  end
end
