# frozen_string_literal: true

module Api
  module V1
    class HistoryItemsController < Api::ApiController
      ATTRIBUTES = [:id, :protonym_id, :position, :taxt, :created_at, :updated_at]

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
