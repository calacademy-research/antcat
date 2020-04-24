# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < Api::ApiController
      def index
        render json: with_limit(Author.all), root: true
      end

      def show
        item = Author.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
