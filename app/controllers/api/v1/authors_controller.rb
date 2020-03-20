module Api
  module V1
    class AuthorsController < Api::ApiController
      def index
        render json: with_limit(Author.all)
      end

      def show
        super Author
      end
    end
  end
end
