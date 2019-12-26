module DatabaseScripts
  class TaxaWithTypeTaxa < DatabaseScript
    def results
      Taxon.where.not(type_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxon, :tt_status, :type_taxon_now, :ttn_status, :cvt_of_tt_if_different_from_ttn
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.now
          cvt_of_type_taxon = type_taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(type_taxon),
            type_taxon.status,
            markdown_taxon_link(type_taxon_now),
            type_taxon_now.status,

            (cvt_of_type_taxon.link_to_taxon + ' ' + cvt_of_type_taxon.status if cvt_of_type_taxon && type_taxon_now != cvt_of_type_taxon)
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


  "CVT of TT if different from TTN" = `current_valid_taxon` of `type_taxon` if different from `type_taxon.now`


  Where `type_taxon.now` is a new experimental function for resolving taxa.

related_scripts:
  - TaxaWithTypeTaxa
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
