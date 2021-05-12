# frozen_string_literal: true

module DatabaseScripts
  class UnpairedSeniorSynonymOfHistoryItems < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.where(type: History::Definitions::SENIOR_SYNONYM_OF).
        joins(<<~SQL.squish).where("history_items_protonyms.protonym_id IS NULL").limit(LIMIT)
          LEFT OUTER JOIN protonyms ON protonyms.id = history_items.object_protonym_id
            LEFT OUTER JOIN history_items history_items_protonyms
            ON (
              history_items_protonyms.protonym_id = protonyms.id
              AND history_items_protonyms.type = 'JuniorSynonymOf'
            )
        SQL
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'to_taxt', 'Missing fact'
        t.rows do |history_item|
          taxt = history_item.to_taxt
          protonym = history_item.protonym

          missing_fact = "JuniorSynonymOf history item is missing for #{history_item.object_protonym.decorate.link_to_protonym}"

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym.decorate.link_to_protonym,
            taxt,
            missing_fact
          ]
        end
      end
    end
  end
end

__END__

section: research
tags: [disagreeing-data, disagreeing-hist, rel-hist, synonyms, future]

description: >
  This script can be ignored for now.


  A quick-fix button could be added to this script, but it would do more harm than good for
  as long as we have a lot of taxt-based history items.


  Ultimately, `SeniorSynonymOf` and `JuniorSynonymOf` items will be merged.

related_scripts:
  - UnpairedJuniorSynonymOfHistoryItems
  - UnpairedSeniorSynonymOfHistoryItems
