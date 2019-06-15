module Api
  module V1
    class NamesController < Api::ApiController
      def index
        super Name
      end

      def show
        super Name
      end
    end
  end
end
