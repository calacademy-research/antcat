# frozen_string_literal: true

module Api
  module V1
    class PublishersController < Api::ApiController
      def index
        render json: with_limit(Publisher.all)
      end

      def show
        item = Publisher.find(params[:id])
        render json: item
      end
    end
  end
end
