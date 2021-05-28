# frozen_string_literal: true

module DatabaseScripts
  class SubspeciesOfHistoryItemsWithNonSpeciesAsTerminalTaxon < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.subspecies_of_relitems.
        joins(object_protonym: :terminal_taxon).
        where.not(taxa: { type: Rank::SPECIES }).limit(LIMIT)
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

title: <code>SubspeciesOf</code> history items with non-species as terminal taxon

section: research
tags: [rel-hist, future]

description: >

related_scripts:
  - SubspeciesOfHistoryItemsWithNonSpeciesAsTerminalTaxon
