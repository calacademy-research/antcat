module Api::V1
  class AuthorNamesController < Api::ApiController
    def index
      authors = AuthorName.all
      render json: authors, status: :ok
    end


    def show
      begin
        authors = AuthorName.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end
      render json: authors, status: :ok
    end

  end
end