# frozen_string_literal: true

module WikiPages
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json do
          render json: serialized_wiki_pages
        end
      end
    end

    private

      def serialized_wiki_pages
        wiki_pages.to_json(root: false, only: [:id, :title])
      end

      def wiki_pages
        search_query = params[:q] || ''
        Autocomplete::WikiPagesQuery[search_query]
      end
  end
end
