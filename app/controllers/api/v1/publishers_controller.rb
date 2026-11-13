# frozen_string_literal: true

# API: publisher records.
#
# Routes: GET /v1/publishers (API); GET /v1/publishers/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class PublishersController < Api::ApiController
      ATTRIBUTES = [:id, :name, :place, :created_at, :updated_at]

      def index
        render json: with_limit(Publisher.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Publisher.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
