# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < Api::ApiController
      def index
        render json: with_limit(Author.all)
      end

      def show
        item = Author.find(params[:id])
        render json: item
      end
    end
  end
end
