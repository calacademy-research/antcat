# frozen_string_literal: true

module DatabaseScripts
  class SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon < DatabaseScript
    def results
      Taxon.synonyms.joins(:current_valid_taxon).where("taxa.protonym_id = current_valid_taxons_taxa.protonym_id").
        includes(protonym: [:name], current_valid_taxon: { protonym: [:name] })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status', 'Shared protonym'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            taxon_link(taxon) + origin_warning(taxon),
            taxon.status,

            taxon_link(current_valid_taxon),
            current_valid_taxon.status,

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

issue_description: This junior synonym belongs to the same protonym as its current valid taxon

description: >

related_scripts:
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym
  - SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon
  - TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms
