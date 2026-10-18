# frozen_string_literal: true

module References
  class ExportsController < ApplicationController
    MAX_RECORDS = 999_999

    def endnote
      references =
        if params[:id]
          Reference.where(id: params[:id])
        else
          fulltext_params = References::Search::ExtractKeywords[params[:reference_q]]
          References::FulltextSearchQuery[
            **fulltext_params.to_solr, per_page: max_records + 1, include_logged_in_only_fields: current_user.present?
          ]
        end

      if !current_user && references.size > max_records
        return render plain: TOO_LARGE_EXPORT_MESSAGE, status: :forbidden
      end

      render plain: Exporters::Endnote::Formatter[references, include_taxonomic_notes: current_user.present?]
    end

    def wikipedia
      reference = find_reference
      render plain: Wikipedia::ReferenceExporter[reference]
    end

    private

      def max_records
        current_user ? MAX_RECORDS : MAX_EXPORT_RECORDS_FOR_VISITORS
      end

      def find_reference
        Reference.find(params.expect(:id))
      end
  end
end
