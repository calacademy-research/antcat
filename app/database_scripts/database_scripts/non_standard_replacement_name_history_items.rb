# frozen_string_literal: true

module DatabaseScripts
  class NonStandardReplacementNameHistoryItems < DatabaseScript
    def results
      HistoryItem.taxts_only.
        where("history_items.taxt LIKE 'Replacement name:%'").
        where.not("taxt REGEXP ?", "^Replacement name: {taxac [0-9]+}\.?$")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Terminal taxon', 'taxt'
        t.rows do |history_item|
          taxt = history_item.taxt

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxon_link(history_item.terminal_taxon),
            taxt
          ]
        end
      end
    end
  end
end

__END__

title: Non-standard 'Replacement name:' history items

section: research
category: History
tags: [new!]

issue_description:

description: >
  This does not mean that they are incorrect, because we want to support these cases:


  * Replacement name: {taxac 441598} ({ref 132776}: 221).

  * Replacement name: {taxac 507625} (replacement name for {taxac 446502}).

related_scripts:
  - NonStandardReplacementNameHistoryItems
