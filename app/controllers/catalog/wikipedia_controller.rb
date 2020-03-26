module Catalog
  class WikipediaController < ApplicationController
    def show
      @taxon = find_taxon
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end
  end
end
