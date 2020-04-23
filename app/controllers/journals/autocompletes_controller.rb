# frozen_string_literal: true

module Journals
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_journals
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
