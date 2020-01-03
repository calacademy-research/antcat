module DatabaseScripts
  class TaxaWithTypeTaxt < DatabaseScript
    def results
      Taxon.where.not(type_taxt: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :type_taxt
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxon.type_taxt]
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
  Table/column: `taxa.type_taxt` (called "Notes" in the "Type" section of the taxon form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  This list contain the same records as the two scripts below (which serve different purposes):


  * Added for investigating "type taxon now" links: %dbscript:TaxaWithTypeTaxtAndATypeTaxon

  * Script that should be fixed: %dbscript:TaxaWithTypeTaxtButNoTypeTaxon

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt

  - TaxaWithTypeTaxa
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues

  - TaxaWithTypeTaxtAndATypeTaxon
  - TaxaWithTypeTaxtButNoTypeTaxon
