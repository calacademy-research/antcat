# frozen_string_literal: true

module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      ATTRIBUTES = [:id, :author_name_id, :reference_id, :position, :created_at, :updated_at]

      def index
        render json: with_limit(ReferenceAuthorName.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = ReferenceAuthorName.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
