# frozen_string_literal: true

module Api
  module V1
    class CitationsController < Api::ApiController
      def index
        render json: with_limit(Citation.all), root: true
      end

      def show
        item = Citation.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
