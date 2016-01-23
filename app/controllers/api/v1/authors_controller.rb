module Api::V1
  class AuthorsController < Api::ApiController
    def index
      @taxa = Author.connection.select_all("SELECT id FROM authors")
      respond_to do |format|
        format.json { render json: @taxa }
      end
    end


    def show
      begin
        authors = Author.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end
      render json: authors, status: :ok
    end

  end
end