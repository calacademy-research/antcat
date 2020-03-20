module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      def index
        render json: with_limit(ReferenceAuthorName.all)
      end

      def show
        item = ReferenceAuthorName.find(params[:id])
        render json: item
      end
    end
  end
end
