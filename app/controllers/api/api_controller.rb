module Api
  class ApiController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def index klass
      items = if params[:starts_at]
                klass.where('id >= ?', params[:starts_at].to_i)
              else
                klass.all
              end.order(id: :asc).limit(100)

      render json: items
    end

    def show klass
      item = klass.find(params[:id])
      render json: item
    end
  end
end
