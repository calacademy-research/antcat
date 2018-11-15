# Secret page. Append "/wikipedia" after the taxon id.

module Catalog
  class WikipediaController < ApplicationController
    before_action :set_taxon, only: :show

    def show
    end

    private

      def set_taxon
        @taxon = Taxon.find params[:id]
      end
  end
end
