# frozen_string_literal: true

module Authors
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json do
          results = Autocomplete::AutocompleteAuthorNames[params[:term]]
          json = if params[:with_ids] # TODO: Start using this instead of just names as strings.
                   results.map { |name| { label: name.name, author_id: name.author_id } }
                 else
                   results.map(&:name)
                 end

          render json: json
        end
      end
    end
  end
end
