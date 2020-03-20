module Api
  class ApiController < ApplicationController
    def index klass
      items = if params[:starts_at]
                klass.where('id >= ?', params[:starts_at].to_i)
              else
                klass.all
              end.order(id: :asc).limit(100)

      render json: items
    end

    def show klass
      begin
        item = klass.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end

      render json: item
    end
  end
end
