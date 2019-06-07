module Catalog
  class RandomController < ApplicationController
    def show
      redirect_to catalog_path(random_taxon_id)
    end

    private

      # TODO: Performance.
      def random_taxon_id
        Taxon.order(Arel.sql('RAND()')).select(:id).first.id
      end
  end
end
