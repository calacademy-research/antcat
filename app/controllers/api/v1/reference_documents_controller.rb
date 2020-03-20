module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      def index
        render json: with_limit(ReferenceDocument.all)
      end

      def show
        super ReferenceDocument
      end
    end
  end
end
