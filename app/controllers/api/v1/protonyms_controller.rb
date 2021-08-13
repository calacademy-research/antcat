# frozen_string_literal: true

module Api
  module V1
    class ProtonymsController < Api::ApiController
      ATTRIBUTES = [
        :id,
        :name_id,
        :authorship_id,
        :sic,
        :fossil,
        :ichnotaxon,
        :bioregion,
        :locality,
        :forms,
        :primary_type_information_taxt,
        :secondary_type_information_taxt,
        :type_notes_taxt,
        :notes_taxt,
        :created_at,
        :updated_at
      ]

      def index
        render json: with_limit(Protonym.all).as_json(only: ATTRIBUTES, root: true)
      end

      def show
        item = Protonym.find(params[:id])
        render json: item.as_json(only: ATTRIBUTES, root: true)
      end
    end
  end
end
