# frozen_string_literal: true

module DatabaseScripts
  class SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon < DatabaseScript
    def results
      Taxon.synonyms.joins(:current_taxon).where("taxa.protonym_id = current_taxa_taxa.protonym_id").
        includes(protonym: [:name], current_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_taxon', 'current_taxon status', 'Shared protonym'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,

            taxon_link(current_taxon),
            current_taxon.status,

            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
tags: [taxa, synonyms]

issue_description: This junior synonym belongs to the same protonym as its current taxon

description: >

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
