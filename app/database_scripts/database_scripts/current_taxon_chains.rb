# frozen_string_literal: true

module DatabaseScripts
  class CurrentTaxonChains < DatabaseScript
    def results
      Taxon.where.not(current_taxon_id: nil).
        joins(:current_taxon).
        where.not(current_taxons_taxa: { current_taxon_id: nil }).
        where(
          'NOT (taxa.status = :obsolete_combination AND current_taxons_taxa.status = :synonym)',
          obsolete_combination: Status::OBSOLETE_COMBINATION,
          synonym: Status::SYNONYM
        ).where.not(status: Status::UNAVAILABLE_MISSPELLING)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_taxon', 'current_taxon status', 'CT of CT', 'CT of CT status'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon
          ct_of_current_taxon = current_taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status,
            taxon_link(ct_of_current_taxon),
            ct_of_current_taxon.status
          ]
        end
      end
    end
  end
end

__END__

section: not-necessarily-incorrect
category: Catalog
tags: [code-changes-required]

issue_description: This taxon has a `current_taxon` which itself has a `current_taxon`.

description: >
  Taxa with a `current_taxon` that has a `current_taxon`.


  Status 'unavailable misspelling' is excluded from **Taxon** (but not **current_taxon**).


  **Taxon** status 'obsolete combination' + **current_taxon** status 'synonym' are also excluded.


  We may want to allow current taxon chains for genus-group names and above (TBD).

related_scripts:
  - CurrentTaxonChains
  - NonValidTaxaSetAsTheCurrentTaxonOfAnotherTaxon
  - NonValidTaxaWithACurrentTaxonThatIsNotValid
  - NonValidTaxaWithJuniorSynonyms
