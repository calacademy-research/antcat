module Api
  module V1
    class PublishersController < Api::ApiController
      def index
        super Publisher
      end

      def show
        super Publisher
      end
    end
  end
end
