# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithRankSpecificHistoryItems < DatabaseScript
    def results
      Protonym.joins(:history_items).where.not(taxon_history_items: { rank: nil }).distinct
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Taxa', 'Ranks of taxa', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.taxa.pluck(:name_cache).join('<br>'),
            protonym.taxa.pluck(:type).join('<br>'),
            protonym.taxa.pluck(:status).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms with rank-specific history items

section: research
category: Protonyms
tags: [slow]

issue_description:

description: >
  This is for the "Protonym items simulation", and ultimately for moving `HistoryItem`s to the protonym.


  See also wiki page: %wiki7

related_scripts:
  - ProtonymsWithRankSpecificAndUnrankedHistoryItems
  - ProtonymsWithRankSpecificHistoryItems
