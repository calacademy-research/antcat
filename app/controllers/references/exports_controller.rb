module References
  class ExportsController < ApplicationController
    def endnote
      id = params[:id]

      references =
        if id
          Reference.where(id: id)
        else
          References::Search::FulltextWithExtractedKeywords[params[:reference_q], per_page: 999_999]
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
