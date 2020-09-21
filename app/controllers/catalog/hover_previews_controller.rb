# frozen_string_literal: true

module Catalog
  class HoverPreviewsController < ApplicationController
    def show
      taxon = find_taxon
      render json: { preview: Taxa::HoverPreview[taxon] }
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end
  end
end
