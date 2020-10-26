# frozen_string_literal: true

module Api
  module V1
    class TaxonHistoryItemsController < Api::ApiController
      ATTRIBUTES = [:id, :protonym_id, :position, :taxt, :created_at, :updated_at]

      def index
        render json: with_limit(HistoryItem.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = HistoryItem.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
