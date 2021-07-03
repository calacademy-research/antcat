# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithLongPages < DatabaseScript
    LIMIT = 150

    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_LIST
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.relational.where("LENGTH(pages) > 20").order("LENGTH(pages) DESC").limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym/TT', 'taxt', 'Pages'
        t.rows do |history_item|
          taxt = history_item.to_taxt

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link_with_terminal_taxa(history_item.protonym),
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
tags: [rel-hist, future]

description: >
  Indicates that the content may belong somewhere else.

related_scripts:
  - HistoryItemsWithLongPages
  - HistoryItemsWithPagesContainingWeirdCharacters
