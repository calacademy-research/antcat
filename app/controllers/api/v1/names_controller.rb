# frozen_string_literal: true

# API: name records.
#
# Routes: GET /v1/names (API); GET /v1/names/:id (API). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Api
  module V1
    class NamesController < Api::ApiController
      ATTRIBUTES = [:id, :epithet, :gender, :name, :created_at, :updated_at]

      def index
        render json: with_limit(Name.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Name.find(params.expect(:id))
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
