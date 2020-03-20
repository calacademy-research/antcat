module Api
  module V1
    class ReferenceSectionsController < Api::ApiController
      def index
        render json: with_limit(ReferenceSection.all)
      end

      def show
        item = ReferenceSection.find(params[:id])
        render json: item
      end
    end
  end
end
