# frozen_string_literal: true

module Catalog
  class BoltonController < ApplicationController
    SUPPORTED_TYPES = [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES, Rank::INFRASUBSPECIES]

    before_action :authenticate_user!

    def show
      @taxon = find_taxon
      @taxa = taxa(@taxon).paginate(page: params[:page])
      @collected_references = collected_references @taxon
    end

    private

      def find_taxon
        Taxon.find(params[:id])
      end

      def taxa taxon
        case taxon
        when SpeciesGroupTaxon then [taxon]
        when Genus             then with_includes(taxon.descendants)
        end
      end

      def with_includes taxa
        TaxonQuery.new(taxa).order_by_epithet.
          includes(:name, :history_items, protonym: [:name, authorship: { reference: :author_names }])
      end

      def collected_references taxon
        return unless taxon.is_a?(SpeciesGroupTaxon)
        Taxa::CollectReferences[taxon].order_by_author_names_and_year.includes(:document)
      end
  end
end
