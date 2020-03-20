module Api
  module V1
    class PublishersController < Api::ApiController
      def index
        render json: with_limit(Publisher.all)
      end

      def show
        super Publisher
      end
    end
  end
end
