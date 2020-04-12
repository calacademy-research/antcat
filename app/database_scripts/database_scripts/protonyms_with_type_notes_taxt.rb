# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTypeNotesTaxt < DatabaseScript
    def results
      Protonym.where.not(type_notes_taxt: nil)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'type_notes_taxt'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            Detax[protonym.type_notes_taxt]
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms with <code>type_notes_taxt</code>

section: list
category: Inline taxt
tags: []

description: >
  **Table/column:** `protonyms.type_notes_taxt` (called "Type notes" in the protonym form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** Keep as is.

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
  - TaxaWithHeadlineNotesTaxt
  - TaxaWithTypeTaxt
