# frozen_string_literal: true

module Api
  module V1
    class NamesController < Api::ApiController
      def index
        render json: with_limit(Name.all), root: true
      end

      def show
        item = Name.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
