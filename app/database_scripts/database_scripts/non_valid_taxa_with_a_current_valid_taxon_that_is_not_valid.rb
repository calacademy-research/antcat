# frozen_string_literal: true

module DatabaseScripts
  class NonValidTaxaWithACurrentValidTaxonThatIsNotValid < DatabaseScript
    def results
      Taxon.excluding_pass_through_names.joins(:current_valid_taxon).
        where.not(current_valid_taxons_taxa: { status: Status::VALID }).
        includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_valid_taxon),
            current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Non-valid taxa with a current valid taxon that is not valid

section: main
category: Catalog
tags: []

issue_description: This [non-pass-through] taxon has a `current_valid_taxon` that is not valid.

description: >
  Pass-through names are not included (statuses `'obsolete combination'` and `'unavailable misspellings'`).

related_scripts:
  - CurrentValidTaxonChains
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
