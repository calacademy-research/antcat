# frozen_string_literal: true

# API: reference sections of taxa.
#
# Routes: GET /v1/reference_sections (API); GET /v1/reference_sections/:id (API). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Api
  module V1
    class ReferenceSectionsController < Api::ApiController
      ATTRIBUTES = [:id, :taxon_id, :position, :title_taxt, :references_taxt, :subtitle_taxt, :created_at, :updated_at]

      def index
        render json: without_hidden_notes(with_limit(ReferenceSection.all).as_json(only: ATTRIBUTES, root: true))
      end

      def show
        item = ReferenceSection.find(params.expect(:id))
        render json: without_hidden_notes(item.as_json(only: ATTRIBUTES, root: true))
      end
    end
  end
end
