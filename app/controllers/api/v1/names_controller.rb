module Api::V1
  class NamesController < Api::ApiController
    def index
      if params[:starts_at]
        starts_at = params[:starts_at]
        names = Name.where('id >= ?',starts_at.to_i).order('id asc').limit('100')
      else
        names = Name.all.order('id asc').limit('100')

      end
      render json: names, status: :ok
    end


    def show
      begin
        names = Name.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end
      render json: names, status: :ok
    end

  end
end