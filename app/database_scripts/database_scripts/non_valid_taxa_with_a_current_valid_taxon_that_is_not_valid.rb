module DatabaseScripts
  class NonValidTaxaWithACurrentValidTaxonThatIsNotValid < DatabaseScript
    def results
      Taxon.excluding_pass_through_names.joins(:current_valid_taxon).
        where.not(current_valid_taxons_taxa: { status: Status::VALID }).
        includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :current_valid_taxon_status
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.current_valid_taxon),
            taxon.current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Non-valid taxa with a current valid taxon that is not valid
category: Catalog
tags: []

issue_description: This [non-pass-through] taxon has a `current_valid_taxon` that is not valid.

description: >
  Pass-through names are not included (statuses `'obsolete combination'` and `'unavailable misspellings'`).

related_scripts:
  - CurrentValidTaxonChains
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
