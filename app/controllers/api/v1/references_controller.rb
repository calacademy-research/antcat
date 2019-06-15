module Api
  module V1
    class ReferencesController < Api::ApiController
      def index
        super Reference
      end

      def show
        super Reference
      end
    end
  end
end
