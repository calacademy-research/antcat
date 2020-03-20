module Api
  class ApiController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
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
