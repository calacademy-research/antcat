# frozen_string_literal: true

module DatabaseScripts
  class SubspeciesOfHistoryItemsWithSubspeciesAsObjectTaxon < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.where(type: History::Definitions::SUBSPECIES_OF).joins(:object_taxon).
        where(taxa: { type: Rank::SUBSPECIES }).limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'to_taxt'
        t.rows do |history_item|
          taxt = history_item.to_taxt
          protonym = history_item.protonym

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym.decorate.link_to_protonym,
            taxt
          ]
        end
      end
    end
  end
end

__END__

title: >
  'Subspecies of' history items with subspecies as object taxon

section: research
category: History
tags: []

description: >

related_scripts:
  - SubspeciesOfHistoryItemsWithSubspeciesAsTerminalTaxon
  - SubspeciesOfHistoryItemsWithSubspeciesAsObjectTaxon
