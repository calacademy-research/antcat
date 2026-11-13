# frozen_string_literal: true

# Wikitext of a taxon for Wikipedia editors.
#
# Routes: GET /catalog/:id/wikipedia (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Catalog
  class WikipediaController < ApplicationController
    def show
      @taxon = find_taxon
    end

    private

      def find_taxon
        Taxon.find(params.expect(:id))
      end
  end
end
