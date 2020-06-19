# frozen_string_literal: true

module Api
  module V1
    class ReferenceDocumentsController < Api::ApiController
      ATTRIBUTES = [:id, :reference_id, :file_file_name, :url, :public, :created_at, :updated_at]

      def index
        render json: with_limit(ReferenceDocument.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = ReferenceDocument.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
