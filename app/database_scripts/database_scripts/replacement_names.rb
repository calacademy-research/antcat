# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNames < DatabaseScript
    def results
      Taxon.joins(:replacement_name_for).
        includes(protonym: [:name], replacement_name_for: :name)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Taxon', 'Status', 'Replacement name for'
        t.rows do |taxon|
          protonym = taxon.protonym

          [
            protonym_link(protonym),
            protonym.author_citation,
            taxon_link(taxon),
            taxon.status,
            taxon_links_with_author_citations(taxon.replacement_name_for)
          ]
        end
      end
    end
  end
end

__END__

section: research
category: Homonyms
tags: [new!, list, slow]

description: >
  **Replacement name for** = via `taxa.homonym_replaced_by_id` (all of which has the status `homonym`)

related_scripts:
  - ReplacementNames
