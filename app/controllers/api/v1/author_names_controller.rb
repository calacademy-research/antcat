# frozen_string_literal: true

module Api
  module V1
    class AuthorNamesController < Api::ApiController
      def index
        render json: with_limit(AuthorName.all), root: true
      end

      def show
        item = AuthorName.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
