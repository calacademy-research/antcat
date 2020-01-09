module Catalog
  class WhatLinksHeresController < ApplicationController
    before_action :set_taxon, only: :show

    def show
      @table_refs = @taxon.what_links_here.all.paginate(page: params[:page])
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:id])
      end
  end
end
