# frozen_string_literal: true

module DatabaseScripts
  class SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon < DatabaseScript
    def results
      Taxon.synonyms.joins(:current_taxon).where("taxa.protonym_id = current_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_taxon', 'current_taxon status', 'Shared protonym'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon) + origin_warning(taxon),
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
category: Catalog
tags: []

issue_description: This junior synonym belongs to the same protonym as its current taxon

description: >

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
