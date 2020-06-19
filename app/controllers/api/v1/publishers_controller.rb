# frozen_string_literal: true

module Api
  module V1
    class PublishersController < Api::ApiController
      ATTRIBUTES = [:id, :name, :place, :created_at, :updated_at]

      def index
        render json: with_limit(Publisher.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Publisher.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
