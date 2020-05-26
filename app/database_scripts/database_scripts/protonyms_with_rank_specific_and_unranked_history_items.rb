# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithRankSpecificAndUnrankedHistoryItems < DatabaseScript
    def results
      Protonym.joins(:history_items).group(:protonym_id).having(<<~SQL)
        COUNT(DISTINCT(CASE WHEN rank IS NULL THEN 'unranked' ELSE 'rank-specific' END)) > 1
      SQL
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Taxa', 'Ranks of taxa', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
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
tags: [new!]

issue_description:

description: >
  This is for the "Protonym items simulation", and ultimately for moving `TaxonHistoryItem`s to the protonym.


  See also wiki page: %wiki7

related_scripts:
  - ProtonymsWithRankSpecificAndUnrankedHistoryItems
  - ProtonymsWithRankSpecificHistoryItems
