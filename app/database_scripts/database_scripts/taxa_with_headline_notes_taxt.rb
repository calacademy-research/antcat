module DatabaseScripts
  class TaxaWithHeadlineNotesTaxt < DatabaseScript
    def results
      Taxon.where.not(headline_notes_taxt: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :headline_notes_taxt
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxon.headline_notes_taxt]
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with <code>headline_notes_taxt</code>
category: Inline taxt
tags: [new!, list]

description: >
  Table/column: `taxa.headline_notes_taxt` (called "Notes" in the upper section of the taxon form)


  This script was mainly added to investigate how we use the different "inline taxt columns".

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt
