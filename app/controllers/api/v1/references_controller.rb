# frozen_string_literal: true

module Api
  module V1
    class ReferencesController < Api::ApiController
      def index
        render json: with_limit(Reference.all).map { |item| Api::V1::ReferenceSerializer.new(item) }
      end

      def show
        item = Reference.find(params[:id])
        render json: Api::V1::ReferenceSerializer.new(item)
      end
    end
  end
end
