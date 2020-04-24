# frozen_string_literal: true

module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      def index
        render json: with_limit(ReferenceDocument.all), root: true
      end

      def show
        item = ReferenceDocument.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
