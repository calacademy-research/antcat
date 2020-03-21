module Api
  module V1
    class CitationsController < Api::ApiController
      def index
        render json: with_limit(Citation.all)
      end

      def show
        item = Citation.find(params[:id])
        render json: item
      end
    end
  end
end
