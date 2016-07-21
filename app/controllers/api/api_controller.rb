module Api
  class ApiController < ApplicationController
    def index klass
      if params[:starts_at]
        starts_at = params[:starts_at]
        items = klass.where('id >= ?', starts_at.to_i).order('id asc').limit('100')
      else
        items = klass.all.order('id asc').limit('100')

      end
      render json: items, status: :ok
    end

    def show klass
      begin
        item = klass.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end

      render json: item, status: :ok
    end
  end
end