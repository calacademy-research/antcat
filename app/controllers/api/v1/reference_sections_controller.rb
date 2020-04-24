# frozen_string_literal: true

module Api
  module V1
    class ReferenceSectionsController < Api::ApiController
      def index
        render json: with_limit(ReferenceSection.all), root: true
      end

      def show
        item = ReferenceSection.find(params[:id])
        render json: item, root: true
      end
    end
  end
end
