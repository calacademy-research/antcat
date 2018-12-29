module Catalog
  class RandomController < ApplicationController
    def show
      redirect_to catalog_path(random_taxon_id)
    end

    private

      # TODO: Performance.
      def random_taxon_id
        offset = rand Taxon.count
        ActiveRecord::Base.connection.execute(<<~SQL).first.first
          SELECT taxa.id
          FROM taxa
          LIMIT 1
          OFFSET #{offset}
        SQL
      end
  end
end
