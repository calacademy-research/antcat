# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithTypeTaxt < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil).includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status',
          'Type taxon', 'Type taxon status',
          'CVT of type taxon if different', 'Status of CVT of type taxon',
          'type_taxt', 'Common taxt?'
        t.rows do |taxon|
          type_taxt = taxon.type_taxt
          type_taxon = taxon.type_taxon
          cvt_of_type_taxon = type_taxon.current_valid_taxon
          different = cvt_of_type_taxon && type_taxon != cvt_of_type_taxon

          [
            taxon_link(taxon),
            taxon.status,

            taxon_link(type_taxon),
            type_taxon.status,

            (taxon_link(cvt_of_type_taxon) if different),
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

section: research
category: Inline taxt
tags: [list, slow]

description: >
  **Table/column:** `taxa.type_taxt` (called "Notes" in the "Type" section of the taxon form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** The goal is to remove this column by first normalizing this data and then move it to the protonym or a new model (work in progress, see %dbscript:MoveTypeTaxonToProtonymByScript).

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt

  - TaxaWithTypeTaxa
  - TaxaWithUncommonTypeTaxts
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
