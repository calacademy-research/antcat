# frozen_string_literal: true

# API: author records.
#
# Routes: GET /v1/authors (API); GET /v1/authors/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class AuthorsController < Api::ApiController
      ATTRIBUTES = [:id, :created_at, :updated_at]

      def index
        render json: with_limit(Author.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Author.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
