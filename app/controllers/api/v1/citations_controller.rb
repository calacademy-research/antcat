# frozen_string_literal: true

module Api
  module V1
    class CitationsController < Api::ApiController
      ATTRIBUTES = [:id, :reference_id, :pages, :created_at, :updated_at]

      def index
        render json: with_limit(Citation.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Citation.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
