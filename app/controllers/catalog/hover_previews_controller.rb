# frozen_string_literal: true

module Catalog
  class HoverPreviewsController < ApplicationController
    def show
      taxon = find_taxon
      render json: { preview: render_preview(taxon) }
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end

      def render_preview taxon
        render_to_string partial: 'catalog/hover_previews/taxon', locals: { taxon: taxon }
      end
  end
end
