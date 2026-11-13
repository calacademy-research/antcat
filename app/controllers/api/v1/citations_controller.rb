# frozen_string_literal: true

# API: citation records.
#
# Routes: GET /v1/citations (API); GET /v1/citations/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class CitationsController < Api::ApiController
      ATTRIBUTES = [:id, :reference_id, :pages, :created_at, :updated_at]

      def index
        render json: with_limit(Citation.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Citation.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
