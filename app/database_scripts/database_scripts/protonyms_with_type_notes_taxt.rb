# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithTypeNotesTaxt < DatabaseScript
    PER_PAGE = 500

    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      Protonym.where.not(type_notes_taxt: nil)
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'Protonym', 'type_notes_taxt'
        t.rows(results_to_render) do |protonym|
          [
            protonym.decorate.link_to_protonym,
            ::Types::FormatTypeField[protonym.type_notes_taxt]
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms with <code>type_notes_taxt</code>

section: research
tags: [protonyms, types, inline-taxt, list]

description: >
  **Table/column:** `protonyms.type_notes_taxt` (called "Type notes" in the protonym form)


  This script was mainly added to investigate how we use the different "inline taxt columns".


  **Plan for this column:** Keep as is.

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithPrimaryTypeInformationTaxt
  - ProtonymsWithSecondaryTypeInformationTaxt
  - ProtonymsWithTypeNotesTaxt
