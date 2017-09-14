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
          Reference.do_search params.merge endnote_export: true
        else
          # I believe it's not possible to get here from the GUI, but the route
          # is not disabled.
          Reference.list_all_references_for_endnote
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
      render plain: Wikipedia::ReferenceExporter.new(@reference).call
    end

    private
      def set_reference
        @reference = Reference.find params[:id]
      end
  end
end
