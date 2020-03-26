# frozen_string_literal: true

module Catalog
  class WhatLinksHeresController < ApplicationController
    def show
      @taxon = find_taxon
      @table_refs = @taxon.what_links_here.all.paginate(page: params[:page])
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end
  end
end
