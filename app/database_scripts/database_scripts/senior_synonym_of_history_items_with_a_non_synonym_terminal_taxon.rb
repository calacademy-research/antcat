# frozen_string_literal: true

module DatabaseScripts
  class SeniorSynonymOfHistoryItemsWithANonSynonymTerminalTaxon < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.senior_synonym_of_relitems.
        joins(object_protonym: :terminal_taxon).where.not(taxa: { status: Status::SYNONYM }).
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym/TT', 'to_taxt', 'PTT status'
        t.rows do |history_item|
          object_protonym_terminal_taxon = history_item.object_protonym.terminal_taxon

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link_with_terminal_taxa(history_item.protonym),
            history_item.to_taxt,
            object_protonym_terminal_taxon&.status
          ]
        end
      end
    end
  end
end

__END__

title: <code>SeniorSynonymOf</code> history items with a non-synonym terminal taxon

section: research
tags: [new!, rel-hist, synonyms, future]

description: >

related_scripts:
  - SeniorSynonymOfHistoryItemsWithANonSynonymTerminalTaxon
