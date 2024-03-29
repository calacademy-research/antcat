# frozen_string_literal: true

module References
  class AutocompletesController < ApplicationController
    def show
      respond_to do |format|
        format.json { render json: serialized_references }
        format.html do
          @references = references
          render layout: false
        end
      end
    end

    private

      def serialized_references
        references.map do |reference|
          Autocomplete::ReferenceSerializer.new(reference, fulltext_params).
            as_json(include_search_query: include_search_query?)
        end
      end

      def references
        Autocomplete::ReferencesQuery[search_query, fulltext_params.to_solr]
      end

      def search_query
        params[:reference_q] || params[:q]
      end

      def fulltext_params
        @_fulltext_params ||= ::References::Search::ExtractKeywords[search_query]
      end

      def include_search_query?
        params[:include_search_query].present?
      end
  end
end
