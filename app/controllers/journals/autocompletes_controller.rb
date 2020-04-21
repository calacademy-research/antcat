# frozen_string_literal: true

module Journals
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json do
          render json: serialized_journals
        end
      end
    end

    private

      def serialized_journals
        journals.pluck(:name)
      end

      def journals
        search_query = params[:term] || ''
        Autocomplete::JournalsQuery[search_query]
      end
  end
end
