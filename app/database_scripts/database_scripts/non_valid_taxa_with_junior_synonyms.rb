# frozen_string_literal: true

module DatabaseScripts
  class NonValidTaxaWithJuniorSynonyms < DatabaseScript
    def results
      Taxon.where.not(status: Status::VALID).joins(:junior_synonyms).distinct
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Non-valid taxa with junior synonyms

section: regression-test
category: Catalog
tags: []

issue_description: This taxon is not valid, but is has junior synonyms.

description: >

related_scripts:
  - CurrentValidTaxonChains
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
