module DatabaseScripts
  class TaxaWithTypeTaxt < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status,
          :type_taxon, :type_taxon_status,
          :cvt_of_type_taxon_if_diffetent, :status_of_cvt_of_type_taxon,
          :type_taxt, :common_taxt?
        t.rows do |taxon|
          type_taxt = taxon.type_taxt
          type_taxon = taxon.type_taxon
          cvt_of_type_taxon = type_taxon.current_valid_taxon
          different = cvt_of_type_taxon && type_taxon != cvt_of_type_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,

            markdown_taxon_link(type_taxon),
            type_taxon.status,

            (markdown_taxon_link(cvt_of_type_taxon) if different),
            (cvt_of_type_taxon.status if different),

            Detax[type_taxt],
            ('Yes' if Protonym.common_type_taxt?(type_taxt))
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with <code>type_taxt</code>
category: Inline taxt
tags: [new!, list, slow]

description: >
  **Table/column:** `taxa.type_taxt` (called "Notes" in the "Type" section of the taxon form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** The goal is to remove this column by first denormalizing this data and then move it to the protonym or a new model (work in progress, see %dbscript:MoveTypeTaxonToProtonymByScript).

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt

  - TaxaWithTypeTaxa
  - TaxaWithUncommonTypeTaxts
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
