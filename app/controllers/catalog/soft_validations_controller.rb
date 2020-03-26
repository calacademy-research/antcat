module Catalog
  class SoftValidationsController < ApplicationController
    def show
      @taxon = find_taxon
      @soft_validations = @taxon.soft_validations
      @protonym_soft_validations = @taxon.protonym.soft_validations
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end
  end
end
