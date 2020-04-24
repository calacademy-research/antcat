# frozen_string_literal: true

module Api
  module V1
    class ProtonymsController < Api::ApiController
      def index
        render json: with_limit(Protonym.all), root: true
      end

      def show
        item = Protonym.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
