module DatabaseScripts
  class TaxaWithTypeTaxa < DatabaseScript
    def results
      Taxon.where.not(type_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :rank, :status, :type_taxon, :tt_rank, :tt_status, :type_taxon_now, :ttn_rank, :ttn_status
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.current_valid_taxon || type_taxon # TODO: Not 100% fool-proof, due to "current_valid_taxon" chains.

          [
            markdown_taxon_link(taxon),
            taxon.rank,
            taxon.status,
            markdown_taxon_link(type_taxon),
            type_taxon.rank,
            type_taxon.status,
            markdown_taxon_link(type_taxon_now),
            type_taxon_now.rank,
            type_taxon_now.status
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [list, new!, slow]

description: >
  Just a list.

related_scripts:
  - TaxaWithTypeTaxa
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
