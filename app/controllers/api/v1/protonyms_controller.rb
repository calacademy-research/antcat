module Api
  module V1
    class ProtonymsController < Api::ApiController
      def index
        protonyms = Protonym.all
        render json: protonyms
      end

      def show
        super Protonym
      end
    end
  end
end
