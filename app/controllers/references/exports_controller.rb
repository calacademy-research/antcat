module References
  class ExportsController < ApplicationController
    before_action :set_reference, only: :wikipedia

    def endnote
      id = params[:id]
      searching = params[:q].present?

      references =
        if id
          # `where` and not `find` because we need to return an array.
          Reference.where(id: id)
        elsif searching
          options = params.merge(endnote_export: true)
          References::Search::FulltextWithExtractedKeywords[options]
        else
          # It's not possible to get here from the GUI (but the route is not disabled).
          all_references_for_endnote
        end

      render plain: Exporters::Endnote::Formatter.format(references)

      rescue
        render plain: <<-MSG.squish
          Looks like something went wrong.
          Exporting missing references is not supported.
          If you tried to export a list of references,
          try to filter the query with "type:nomissing".
        MSG
    end

    def wikipedia
      render plain: Wikipedia::ReferenceExporter[@reference]
    end

    private

      def set_reference
        @reference = Reference.find params[:id]
      end

    def all_references_for_endnote
      Reference.joins(:author_names).
        includes(:journal, :author_names, :document, [{ publisher: :place }]).
        where.not(type: 'MissingReference').all
    end
  end
end
