module Api
  class ApiController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def index klass
      items = with_limit(klass.all)
      render json: items
    end

    def show klass
      item = klass.find(params[:id])
      render json: item
    end

    private

      def with_limit scope
        if params[:starts_at]
          scope.where('id >= ?', params[:starts_at].to_i)
        else
          scope
        end.order(id: :asc).limit(100)
      end
  end
end
