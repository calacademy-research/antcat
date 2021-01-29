# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithRankSpecificAndUnrankedHistoryItems < DatabaseScript
    def results
      ranked_and_unranked =
        Protonym.joins(:history_items).group("protonyms.id").having(<<~SQL.squish)
          COUNT(DISTINCT(CASE WHEN rank IS NULL THEN 'unranked' ELSE 'rank-specific' END)) > 1
        SQL
      Protonym.where(id: ranked_and_unranked.select("protonyms.id"))
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

title: Protonyms with rank-specific and unranked history items

section: research
category: Protonyms
tags: [list]

description: >

related_scripts:
  - ProtonymsWithRankSpecificAndUnrankedHistoryItems
  - ProtonymsWithRankSpecificHistoryItems
