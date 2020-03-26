# frozen_string_literal: true

module Api
  module V1
    class ReferencesController < Api::ApiController
      def index
        render json: with_limit(Reference.all)
      end

      def show
        item = Reference.find(params[:id])
        render json: item
      end
    end
  end
end
