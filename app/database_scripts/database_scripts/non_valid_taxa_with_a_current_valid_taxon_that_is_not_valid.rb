module DatabaseScripts
  class NonValidTaxaWithACurrentValidTaxonThatIsNotValid < DatabaseScript
    def results
      Taxon.where.not(current_valid_taxon: nil).where.not(status: Status::PASS_THROUGH_NAMES).
        self_join_on(:current_valid_taxon).where.not(taxa_self_join_alias: { status: Status::VALID })
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

description: >
  Pass-through names are not included (statuses `'obsolete combination'` and `'unavailable misspellings'`).

related_scripts:
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
