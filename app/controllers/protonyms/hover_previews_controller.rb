# frozen_string_literal: true

# The preview shown when hovering a protonym link.
#
# Routes: GET /protonyms/:protonym_id/hover_preview (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Protonyms
  class HoverPreviewsController < ApplicationController
    def show
      protonym = find_protonym
      render json: { preview: render_preview(protonym) }
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end

      def render_preview protonym
        render_to_string formats: :html,
          partial: 'protonyms/hover_previews/protonym', locals: { protonym: protonym }
      end
  end
end
