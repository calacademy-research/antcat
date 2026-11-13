# frozen_string_literal: true

# The small preview shown when hovering a taxon link.
#
# Routes: GET /catalog/:id/hover_preview (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Catalog
  class HoverPreviewsController < ApplicationController
    def show
      taxon = find_taxon
      render json: { preview: render_preview(taxon) }
    end

    private

      def find_taxon
        Taxon.find(params.expect(:id))
      end

      def render_preview taxon
        render_to_string formats: :html,
          partial: 'catalog/hover_previews/taxon', locals: { taxon: taxon }
      end
  end
end
