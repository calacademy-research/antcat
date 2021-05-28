# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsByNumberOfHistoryItemsAsObject < DatabaseScript
    LIMIT = 100

    def statistics
    end

    def results
      Protonym.joins(:history_items_as_object).
        merge(HistoryItem.relational).
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

title: Protonyms by number of history items as object

section: list
tags: [protonyms, stats, rel-hist]

description: >

related_scripts:
  - ProtonymsByNumberOfHistoryItems
  - ProtonymsByNumberOfHistoryItemsAsObject
  - ProtonymsByNumberOfTaxtHistoryItems
  - ReferencesByNumberOfHistoryItems
