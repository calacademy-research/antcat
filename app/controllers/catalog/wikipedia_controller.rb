# frozen_string_literal: true

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
