module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      def index
        super ReferenceDocument
      end

      def show
        super ReferenceDocument
      end
    end
  end
end
