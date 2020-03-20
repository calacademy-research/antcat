module Api
  module V1
    class CitationsController < Api::ApiController
      def index
        render json: with_limit(Citation.all)
      end

      def show
        super Citation
      end
    end
  end
end
