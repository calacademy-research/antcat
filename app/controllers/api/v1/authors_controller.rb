module Api::V1
  class AuthorsController < Api::ApiController
    def index
      authors = Author.all
      render json: authors, status: :ok
    end

    def show
      super Author
    end
  end
end
