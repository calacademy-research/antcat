module References
  class ExportsController < ApplicationController
    before_action :set_reference, only: :wikipedia

    def endnote
      id = params[:id]

      references =
        if id
          Reference.where(id: id)
        else
          References::Search::FulltextWithExtractedKeywords[params[:reference_q], endnote_export: true]
        end

      render plain: Exporters::Endnote::Formatter.format(references)
    end

    def wikipedia
      render plain: Wikipedia::ReferenceExporter[@reference]
    end

    private

      def set_reference
        @reference = Reference.find(params[:id])
      end
  end
end
