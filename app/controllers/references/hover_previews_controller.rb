# frozen_string_literal: true

# The preview shown when hovering a reference link.
#
# Routes: GET /references/:reference_id/hover_preview (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module References
  class HoverPreviewsController < ApplicationController
    def show
      reference = find_reference
      render json: { preview: render_preview(reference) }
    end

    private

      def find_reference
        Reference.find(params.expect(:reference_id))
      end

      def render_preview reference
        render_to_string formats: :html,
          partial: 'references/hover_previews/reference', locals: { reference: reference }
      end
  end
end
