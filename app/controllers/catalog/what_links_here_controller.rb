module Catalog
  class WhatLinksHereController < ApplicationController
    before_action :set_taxon, only: :index

    def index
      @table_refs = @taxon.what_links_here.paginate(page: params[:page], per_page: 100)
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:id])
      end
  end
end
