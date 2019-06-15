module Api
  module V1
    class TaxonHistoryItemsController < Api::ApiController
      def index
        super TaxonHistoryItem
      end

      def show
        super TaxonHistoryItem
      end
    end
  end
end
