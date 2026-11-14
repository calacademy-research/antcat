# frozen_string_literal: true

# A random taxon page.
#
# Routes: GET /catalog/random (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Catalog
  class RandomController < ApplicationController
    def show
      redirect_to catalog_path(random_taxon_id)
    end

    private

      # PERFORMANCE: Not critical, just a reminder about `RAND()`.
      def random_taxon_id
        Taxon.order(Arel.sql('RAND()')).select(:id).first.id
      end
  end
end
