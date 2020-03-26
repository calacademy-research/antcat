# frozen_string_literal: true

module Api
  module V1
    class ProtonymsController < Api::ApiController
      def index
        render json: with_limit(Protonym.all)
      end

      def show
        item = Protonym.find(params[:id])
        render json: item
      end
    end
  end
end
