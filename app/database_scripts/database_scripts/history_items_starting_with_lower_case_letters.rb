# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsStartingWithLowerCaseLetters < DatabaseScript
    LIMIT = 100

    def results
      TaxonHistoryItem.where("BINARY taxt REGEXP ?", "^(<i>)?[a-z]").includes(:taxon).limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Taxt
tags: [new!]

issue_description:

description: >

related_scripts:
  - HistoryItemsStartingWithLowerCaseLetters
