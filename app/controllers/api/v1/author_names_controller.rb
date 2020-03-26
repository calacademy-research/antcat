# frozen_string_literal: true

module Api
  module V1
    class AuthorNamesController < Api::ApiController
      def index
        render json: with_limit(AuthorName.all)
      end

      def show
        item = AuthorName.find(params[:id])
        render json: item
      end
    end
  end
end
