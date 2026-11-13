# frozen_string_literal: true

# API: reference records.
#
# Routes: GET /v1/references (API); GET /v1/references/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class ReferencesController < Api::ApiController
      def index
        render json: with_limit(Reference.all).map { Api::V1::ReferenceSerializer.new(it) }
      end

      def show
        item = Reference.find(params.expect(:id))
        render json: Api::V1::ReferenceSerializer.new(item)
      end
    end
  end
end
