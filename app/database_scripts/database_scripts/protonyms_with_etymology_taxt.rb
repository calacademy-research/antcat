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
        t.header 'Protonym', 'etymology_taxt'
        t.rows do |protonym|
          [
            protonym_link(protonym),
            protonym.etymology_taxt
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
tags: [list, new!]

description: >

related_scripts:
  - ProtonymsWithEtymologyTaxt
  - ProtonymsWithNotesTaxt
  - ProtonymsWithTypeNotesTaxt
