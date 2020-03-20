module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      def index
        render json: with_limit(ReferenceAuthorName.all)
      end

      def show
        super ReferenceAuthorName
      end
    end
  end
end
