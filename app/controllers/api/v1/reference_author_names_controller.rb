# frozen_string_literal: true

# API: links between references and author names.
#
# Routes: GET /v1/reference_author_names (API); GET /v1/reference_author_names/:id (API). Purpose, rights and tests
# of each: docs/catalog/routes.tsv.
module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      ATTRIBUTES = [:id, :author_name_id, :reference_id, :position, :created_at, :updated_at]

      def index
        render json: with_limit(ReferenceAuthorName.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = ReferenceAuthorName.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
