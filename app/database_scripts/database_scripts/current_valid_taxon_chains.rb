module DatabaseScripts
  class CurrentValidTaxonChains < DatabaseScript
    def results
      Taxon.where.not(current_valid_taxon_id: nil).
        joins(:current_valid_taxon).
        where.not(current_valid_taxons_taxa: { current_valid_taxon_id: nil })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_valid_taxon', 'current_valid_taxon status', 'CVT of CVT', 'CVT of CVT status'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon
          cvt_of_current_valid_taxon = current_valid_taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon) + origin_warning(taxon),
            taxon.status,
            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status,
            markdown_taxon_link(cvt_of_current_valid_taxon),
            cvt_of_current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: []

issue_description: This taxon has a `current_valid_taxon` which itself has a `current_valid_taxon`.

description: >
  Taxa with a `current_valid_taxon` that has a `current_valid_taxon`.


  This is not necessarily incorrect.

related_scripts:
  - CurrentValidTaxonChains
  - NonValidTaxaSetAsTheCurrentValidTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentValidTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
