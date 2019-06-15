module Api
  module V1
    class CitationsController < Api::ApiController
      def index
        super Citation
      end

      def show
        super Citation
      end
    end
  end
end
