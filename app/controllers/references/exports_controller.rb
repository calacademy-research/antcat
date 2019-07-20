module References
  class ExportsController < ApplicationController
    before_action :set_reference, only: :wikipedia

    def endnote
      id = params[:id]
      searching = params[:q].present?

      references =
        if id
          Reference.where(id: id)
        elsif searching
          options = params.merge(endnote_export: true)
          References::Search::FulltextWithExtractedKeywords[options]
        end

      render plain: Exporters::Endnote::Formatter.format(references)
    rescue StandardError
      render plain: <<-MSG.squish
        Looks like something went wrong. Exporting missing references is not supported.
        If you tried to export a list of references, try to filter the query with "type:nomissing".
      MSG
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
