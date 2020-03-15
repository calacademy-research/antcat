module DatabaseScripts
  class TaxaWithHeadlineNotesTaxt < DatabaseScript
    def results
      Taxon.where.not(headline_notes_taxt: nil)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'headline_notes_taxt'
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
tags: [list]

description: >
  **Table/column:** `taxa.headline_notes_taxt` (called "Notes" in the upper section of the taxon form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** The goal is to remove this column somehow, since it is too much of a special case and we want to avoid "inline taxts".


  As of writing, a lot of the data here belongs to history items or `protonyms.notes_taxt` ("Section designated to include ...", see %dbscript:ProtonymsWithNotesTaxt.


  "Genbank accession numbers" do not really belong anywhere, but we could add new column or table for it.

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt
