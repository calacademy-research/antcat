# frozen_string_literal: true

module Catalog
  class WhatLinksHeresController < ApplicationController
    def show
      @taxon = find_taxon
      @what_links_here_items = @taxon.what_links_here.all.paginate(page: params[:page])
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end
  end
end
