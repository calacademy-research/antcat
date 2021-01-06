# frozen_string_literal: true

module References
  class HoverPreviewsController < ApplicationController
    def show
      reference = find_reference
      render json: { preview: render_preview(reference) }
    end

    private

      def find_reference
        Reference.find(params[:reference_id])
      end

      def render_preview reference
        render_to_string partial: 'references/hover_previews/reference', locals: { reference: reference }
      end
  end
end
