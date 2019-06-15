module Api
  module V1
    class SynonymsController < Api::ApiController
      def index
        super Synonym
      end

      def show
        super Synonym
      end
    end
  end
end
