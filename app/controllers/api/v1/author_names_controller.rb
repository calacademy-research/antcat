module Api
  module V1
    class AuthorNamesController < Api::ApiController
      def index
        authors = AuthorName.all
        render json: authors
      end

      def show
        super AuthorName
      end
    end
  end
end
