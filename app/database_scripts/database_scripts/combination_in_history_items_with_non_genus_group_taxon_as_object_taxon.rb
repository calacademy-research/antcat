# frozen_string_literal: true

module DatabaseScripts
  class CombinationInHistoryItemsWithNonGenusGroupTaxonAsObjectTaxon < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.combination_in_relitems.joins(:object_taxon).
        where.not(taxa: { type: Rank::GENUS_GROUP_NAMES }).limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym/TT', 'to_taxt'
        t.rows do |history_item|
          taxt = history_item.to_taxt
          protonym = history_item.protonym

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link_with_terminal_taxa(protonym),
            taxt
          ]
        end
      end
    end
  end
end
__END__

title: >
  'Combination in' history items with non-genus group taxon as object taxon

section: research
tags: [rel-hist, combinations, future]

description: >

related_scripts:
  - CombinationInHistoryItemsWithNonGenusGroupTaxonAsObjectTaxon
