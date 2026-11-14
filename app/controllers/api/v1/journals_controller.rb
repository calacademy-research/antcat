# frozen_string_literal: true

# API: journal records.
#
# Routes: GET /v1/journals (API); GET /v1/journals/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class JournalsController < Api::ApiController
      ATTRIBUTES = [:id, :name, :created_at, :updated_at]

      def index
        render json: with_limit(Journal.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Journal.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
