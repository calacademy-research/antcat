# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithNotesTaxt < DatabaseScript
    PARSABLE_VARIATIONS = [
      /^ ?\[as subgenus of \{tax \d+\}\]$/,
      /^ ?\[as "section" of \{tax \d+\}\]$/,
      /^ ?\[as "group" of \{tax \d+\}\]$/,
      /^ ?\[as "branch" of \{tax \d+\}\]$/
    ]

    def results
      Protonym.joins(:authorship).where.not(citations: { notes_taxt: nil }).includes(:name, :authorship)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'notes_taxt', 'notes_type'
        t.rows do |protonym|
          notes_taxt = protonym.authorship.notes_taxt

          [
            protonym.decorate.link_to_protonym,
            Detax[notes_taxt],
            notes_type(notes_taxt)
          ]
        end
      end
    end

    private

      def notes_type notes_taxt
        return 'as_x_of_tax_id' if PARSABLE_VARIATIONS.any? { |re| re =~ notes_taxt }
      end
  end
end

__END__

title: Protonyms with <code>notes_taxt</code>

section: research
category: Inline taxt
tags: [list]

description: >
  **Table/column:** `citations.notes_taxt` (called "Notes" in the protonym form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** No plan right now, but it would be nice to normalize it.


  Some of the data here belongs more to `protonyms.forms` or `protonyms.type_notes_taxt` (see %dbscript:ProtonymsWithTypeNotesTaxt).

related_scripts:
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
