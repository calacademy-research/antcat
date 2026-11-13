# frozen_string_literal: true

# API: author name records.
#
# Routes: GET /v1/author_names (API); GET /v1/author_names/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class AuthorNamesController < Api::ApiController
      ATTRIBUTES = [:id, :author_id, :name, :created_at, :updated_at]

      def index
        render json: with_limit(AuthorName.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = AuthorName.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
