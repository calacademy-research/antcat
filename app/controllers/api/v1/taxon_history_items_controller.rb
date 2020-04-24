# frozen_string_literal: true

module Api
  module V1
    class TaxonHistoryItemsController < Api::ApiController
      def index
        render json: with_limit(TaxonHistoryItem.all), root: true
      end

      def show
        item = TaxonHistoryItem.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
