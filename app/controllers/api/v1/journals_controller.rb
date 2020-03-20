module Api
  module V1
    class JournalsController < Api::ApiController
      def index
        render json: with_limit(Journal.all)
      end

      def show
        super Journal
      end
    end
  end
end
