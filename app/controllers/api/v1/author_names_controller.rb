module Api
  module V1
    class AuthorNamesController < Api::ApiController
      def index
        render json: with_limit(AuthorName.all)
      end

      def show
        super AuthorName
      end
    end
  end
end
