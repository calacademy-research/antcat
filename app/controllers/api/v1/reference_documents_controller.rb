# frozen_string_literal: true

# API: reference document (PDF) records.
#
# Routes: GET /v1/reference_documents (API); GET /v1/reference_documents/:id (API). Purpose, rights and tests of
# each: docs/catalog/routes.tsv.
module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      ATTRIBUTES = [:id, :reference_id, :file_file_name, :url, :created_at, :updated_at]

      def index
        render json: with_limit(ReferenceDocument.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = ReferenceDocument.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
