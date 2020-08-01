# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithNomenAttributes < DatabaseScript
    LIMIT = 300

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Protonym.where(<<~SQL).limit(LIMIT)
        nomen_novum = TRUE OR
          nomen_oblitum = TRUE OR
          nomen_dubium = TRUE OR
          nomen_conservandum = TRUE OR
          nomen_protectum = TRUE
      SQL
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Nomen attributes'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.decorate.format_nomen_attributes
          ]
        end
      end
    end
  end
end

__END__

section: research
category: Protonyms
tags: [new!]

issue_description:

description: >
  *Nomina nuda* are not included (use the search form).

related_scripts:
  - ProtonymsWithNomenAttributes
