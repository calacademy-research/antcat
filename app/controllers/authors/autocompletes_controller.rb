# frozen_string_literal: true

module Authors
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json do
          render json: serialized_author_names
        end
      end
    end

    private

      def serialized_author_names
        if params[:with_ids] # TODO: Start using this instead of just names as strings.
          author_names.map { |name| { label: name.name, author_id: name.author_id } }
        else
          author_names.map(&:name)
        end
      end

      def author_names
        Autocomplete::AuthorNamesQuery[params[:term]]
      end
  end
end
