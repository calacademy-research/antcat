# frozen_string_literal: true

module Api
  module V1
    class HistoryItemsController < Api::ApiController
      # Relational history items (type other than Taxt) keep their content in these fields, not in `taxt`.
      RELATIONAL_ATTRIBUTES = [
        :type, :subtype, :rank, :picked_value, :text_value, :reference_id, :pages,
        :object_protonym_id, :object_taxon_id, :force_author_citation
      ]
      ATTRIBUTES = [:id, :protonym_id, :position, :taxt, *RELATIONAL_ATTRIBUTES, :created_at, :updated_at]

      def index
        render json: without_hidden_notes(with_limit(HistoryItem.all).as_json(only: ATTRIBUTES, root: true))
      end

      def show
        item = HistoryItem.find(params.expect(:id))
        render json: without_hidden_notes(item.as_json(only: ATTRIBUTES, root: true))
      end
    end
  end
end
