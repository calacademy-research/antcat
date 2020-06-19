# frozen_string_literal: true

module Api
  module V1
    class JournalsController < Api::ApiController
      ATTRIBUTES = [:id, :name, :created_at, :updated_at]

      def index
        render json: with_limit(Journal.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Journal.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
