# frozen_string_literal: true

# Database checks of one taxon.
#
# Routes: GET /catalog/:id/soft_validations (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Catalog
  class SoftValidationsController < ApplicationController
    def show
      @taxon = find_taxon
      @soft_validations = @taxon.soft_validations
      @protonym = @taxon.protonym
      @protonym_soft_validations = @protonym.soft_validations
    end

    private

      def find_taxon
        Taxon.find(params.expect(:id))
      end
  end
end
