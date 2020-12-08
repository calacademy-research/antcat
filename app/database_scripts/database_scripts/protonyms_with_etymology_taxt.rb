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
        t.header 'Protonym', 'Terminal taxon', 'etymology_taxt', 'gender_agreement_type'
        t.rows do |protonym|
          [
            protonym_link(protonym),
            (taxon_link(protonym.terminal_taxon) if protonym.terminal_taxon),
            protonym.etymology_taxt,
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
category: Inline taxt
tags: [list]

description: >

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithPrimaryTypeInformationTaxt
  - ProtonymsWithSecondaryTypeInformationTaxt
  - ProtonymsWithTypeNotesTaxt
