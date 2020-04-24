# frozen_string_literal: true

module Api
  module V1
    class JournalsController < Api::ApiController
      def index
        render json: with_limit(Journal.all), root: true
      end

      def show
        item = Journal.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
