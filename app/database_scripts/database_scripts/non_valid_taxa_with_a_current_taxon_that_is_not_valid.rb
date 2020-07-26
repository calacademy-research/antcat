# frozen_string_literal: true

module DatabaseScripts
  class NonValidTaxaWithACurrentTaxonThatIsNotValid < DatabaseScript
    def results
      TaxonQuery.new.excluding_pass_through_names.joins(:current_taxon).
        where.not(current_taxons_taxa: { status: Status::VALID }).
        includes(:current_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_taxon', 'current_taxon status'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Non-valid taxa with a current taxon that is not valid

section: regression-test
category: Catalog
tags: []

issue_description: This [non-pass-through] taxon has a `current_taxon` that is not valid.

description: >
  Pass-through names are not included (statuses `'obsolete combination'` and `'unavailable misspellings'`).

related_scripts:
  - CurrentTaxonChains
  - NonValidTaxaWithACurrentTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
