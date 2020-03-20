module Api
  module V1
    class TaxonHistoryItemsController < Api::ApiController
      def index
        render json: with_limit(TaxonHistoryItem.all)
      end

      def show
        super TaxonHistoryItem
      end
    end
  end
end
