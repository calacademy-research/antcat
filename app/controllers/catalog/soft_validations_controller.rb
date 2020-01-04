module Catalog
  class SoftValidationsController < ApplicationController
    before_action :set_taxon, only: :show

    def show
      @soft_validations = @taxon.soft_validations
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:id])
      end
  end
end
