module Api
  module V1
    class ReferencesController < Api::ApiController
      def index
        render json: with_limit(Reference.all)
      end

      def show
        super Reference
      end
    end
  end
end
