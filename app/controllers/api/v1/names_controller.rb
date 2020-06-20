# frozen_string_literal: true

module Api
  module V1
    class NamesController < Api::ApiController
      ATTRIBUTES = [:id, :auto_generated, :epithet, :gender, :name, :nonconforming_name, :origin, :created_at, :updated_at]

      def index
        render json: with_limit(Name.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Name.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
