# frozen_string_literal: true

module Catalog
  class WhatLinksHeresController < ApplicationController
    def show
      @taxon = find_taxon
      items = @taxon.what_links_here.all
      # Visitors do not see links that exist only inside hidden notes.
      items = WhatLinksHereVisibleItems[items, @taxon, :taxon] unless Current.signed_in
      @what_links_here_items = items.paginate(page: params[:page])
    end

    private

      def find_taxon
        Taxon.find(params.expect(:id))
      end
  end
end
