# frozen_string_literal: true

module Protonyms
  class HoverPreviewsController < ApplicationController
    def show
      protonym = find_protonym
      render json: { preview: render_preview(protonym) }
    end

    private

      def find_protonym
        Protonym.find(params[:protonym_id])
      end

      def render_preview protonym
        render_to_string partial: 'protonyms/hover_previews/protonym', locals: { protonym: protonym }
      end
  end
end
