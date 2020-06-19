# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < Api::ApiController
      ATTRIBUTES = [:id, :created_at, :updated_at]

      def index
        render json: with_limit(Author.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Author.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
