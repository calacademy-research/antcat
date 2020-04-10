# frozen_string_literal: true

module References
  class ExportsController < ApplicationController
    def endnote
      id = params[:id]

      references =
        if id
          Reference.where(id: id)
        else
          fulltext_params = References::Search::ExtractKeywords[params[:reference_q]]
          References::Search::Fulltext[**fulltext_params, per_page: 999_999]
        end

      render plain: Exporters::Endnote::Formatter[references]
    end

    def wikipedia
      @reference = find_reference
      render plain: Wikipedia::ReferenceExporter[@reference]
    end

    private

      def find_reference
        Reference.find(params[:id])
      end
  end
end
