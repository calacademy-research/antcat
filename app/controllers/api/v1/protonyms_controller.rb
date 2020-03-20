module Api
  module V1
    class ProtonymsController < Api::ApiController
      def index
        render json: with_limit(Protonym.all)
      end

      def show
        super Protonym
      end
    end
  end
end
