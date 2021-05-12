# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithRankSpecificHistoryItems < DatabaseScript
    def results
      Protonym.joins(:history_items).where.not(history_items: { rank: nil }).distinct
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
tags: [taxt/rel-hist, slow]

description: >

related_scripts:
  - ProtonymsWithRankSpecificAndUnrankedHistoryItems
  - ProtonymsWithRankSpecificHistoryItems
