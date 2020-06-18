# frozen_string_literal: true

module DatabaseScripts
  class NonValidTaxaSetAsTheCurrentTaxonOfAnotherTaxon < DatabaseScript
    def results
      taxa_set_as_current_taxon.invalid
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.rank,
            taxon.status
          ]
        end
      end
    end

    private

      def taxa_set_as_current_taxon
        taxa_with_a_current_taxon = Taxon.where.not(current_taxon_id: nil).select(:current_taxon_id)
        Taxon.where(id: taxa_with_a_current_taxon)
      end
  end
end

__END__

title: Non-valid taxa set as the current taxon of another taxon

section: list
category: Catalog
tags: []

description: >
  This is not necessarily incorrect, but the name of the database column is `current_taxon_id`,
  which does refect how it's used. This script was added as a part of investigating %github814.

related_scripts:
  - CurrentTaxonChains
  - NonValidTaxaSetAsTheCurrentTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
