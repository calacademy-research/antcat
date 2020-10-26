# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsStartingWithLowerCaseLetters < DatabaseScript
    LIMIT = 100

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.where("BINARY taxt REGEXP ?", "^(<i>)?[a-z]").limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Status', 'taxt'
        t.rows do |history_item|
          taxt = history_item.taxt

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Taxt
tags: []

issue_description:

description: >

related_scripts:
  - HistoryItemsStartingWithLowerCaseLetters
