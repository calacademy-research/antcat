# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithNotesTaxt < DatabaseScript
    PER_PAGE = 1000

    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      Protonym.where.not(notes_taxt: nil).includes(:name, :authorship)
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'Protonym', 'notes_taxt', 'notes_type'
        t.rows(results_to_render) do |protonym|
          notes_taxt = protonym.notes_taxt

          [
            protonym.decorate.link_to_protonym,
            notes_taxt,
            notes_type(notes_taxt)
          ]
        end
      end
    end

    private

      def notes_type notes_taxt
        return 'as_x_of_tax_id' if Protonyms.semi_normalized_notes_taxt?(notes_taxt)
      end
  end
end

__END__

title: Protonyms with <code>notes_taxt</code>

section: research
tags: [protonyms, inline-taxt, list]

description: >
  **Table/column:** `protonyms.notes_taxt` called "Notes" in the protonym form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** No plan right now, but it would be nice to normalize it.


  Some of the data here belongs more to `protonyms.forms` or `protonyms.type_notes_taxt` (see %dbscript:ProtonymsWithTypeNotesTaxt).

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithPrimaryTypeInformationTaxt
  - ProtonymsWithSecondaryTypeInformationTaxt
  - ProtonymsWithTypeNotesTaxt
