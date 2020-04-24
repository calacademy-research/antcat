# frozen_string_literal: true

module Api
  module V1
    class PublishersController < Api::ApiController
      def index
        render json: with_limit(Publisher.all), root: true
      end

      def show
        item = Publisher.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
