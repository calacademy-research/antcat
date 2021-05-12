# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsByNumberOfTaxtHistoryItems < DatabaseScript
    LIMIT = 100

    def statistics
    end

    def results
      Protonym.joins(:history_items).
        where(history_items: { type: History::Definitions::TAXT }).
        group(:id).order("COUNT(history_items.id) DESC").limit(LIMIT).
        select("protonyms.*, COUNT(history_items.id) AS history_item_count")
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'History item count'
        t.rows do |protonym|
          [
            protonym_link(protonym),
            protonym.history_item_count
          ]
        end
      end
    end
  end
end

__END__

title: Protonyms by number of taxt history items

section: list
tags: [protonyms, stats, taxt-hist]

description: >

related_scripts:
  - ProtonymsByNumberOfHistoryItems
  - ProtonymsByNumberOfHistoryItemsAsObject
  - ProtonymsByNumberOfTaxtHistoryItems
  - ReferencesByNumberOfHistoryItems
