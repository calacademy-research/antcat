module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      def index
        render json: with_limit(ReferenceDocument.all)
      end

      def show
        item = ReferenceDocument.find(params[:id])
        render json: item
      end
    end
  end
end
