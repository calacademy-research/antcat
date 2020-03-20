module Api
  module V1
    class NamesController < Api::ApiController
      def index
        render json: with_limit(Name.all)
      end

      def show
        super Name
      end
    end
  end
end
