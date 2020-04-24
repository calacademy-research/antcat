# frozen_string_literal: true

module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      def index
        render json: with_limit(ReferenceAuthorName.all), root: true
      end

      def show
        item = ReferenceAuthorName.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
