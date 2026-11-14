# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithEtymologyTaxt < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def results
      Protonym.where.not(etymology_taxt: nil).includes(:name, :authorship)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Terminal taxon', 'etymology_taxt', 'Source', 'gender_agreement_type'
        t.rows do |protonym|
          [
            protonym_link(protonym),
            (taxon_link(protonym.terminal_taxon) if protonym.terminal_taxon),
            protonym.etymology_taxt,
            protonym.etymology_source? ? "#{protonym.etymology_source_label}: #{protonym.etymology_pages}" : 'not recorded',
            protonym.gender_agreement_type
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms with <code>etymology_taxt</code>

section: research
tags: [protonyms, names, inline-taxt, list]

description: >
  "Source: not recorded" marks an etymology entered before the source fields (November 2026); it is not
  yet checked as the author's words as printed.

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithPrimaryTypeInformationTaxt
  - ProtonymsWithSecondaryTypeInformationTaxt
  - ProtonymsWithTypeNotesTaxt
