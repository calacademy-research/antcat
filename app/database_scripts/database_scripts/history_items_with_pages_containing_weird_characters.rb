# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithPagesContainingWeirdCharacters < DatabaseScript
    LIMIT = 150

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.relational.where("pages REGEXP ?", "[^0-9A-Za-z -\\.,\\(\\)]").limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'taxt', 'Pages'
        t.rows do |history_item|
          taxt = history_item.to_taxt

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxt,
            history_item.pages
          ]
        end
      end
    end
  end
end

__END__

section: research
tags: [rel-hist, future, list]

description: >
  Indicates that the content may belong somewhere else.

related_scripts:
  - HistoryItemsWithLongPages
  - HistoryItemsWithPagesContainingWeirdCharacters
