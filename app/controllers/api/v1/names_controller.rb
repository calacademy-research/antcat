# frozen_string_literal: true

module Api
  module V1
    class NamesController < Api::ApiController
      def index
        render json: with_limit(Name.all)
      end

      def show
        item = Name.find(params[:id])
        render json: item
      end
    end
  end
end
