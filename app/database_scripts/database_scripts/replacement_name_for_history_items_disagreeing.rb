# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameForHistoryItemsDisagreeing < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      HistoryItem.taxts_only.where("history_items.taxt LIKE 'Replacement name for {tax%'")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Terminal taxon', 'taxt', 'Extracted taxon', 'ET homonym_replaced_by', 'OK?'
        t.rows do |history_item|
          taxt = history_item.taxt
          extracted_taxon = Taxon.find(history_item.ids_from_taxon_tags.first)

          same = extracted_taxon.homonym_replaced_by == history_item.terminal_taxon

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxon_link(history_item.terminal_taxon),
            taxt,
            taxon_link(extracted_taxon),
            taxon_link(extracted_taxon.homonym_replaced_by),
            (same ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

title: >
  'Replacement name for' history items (disagreeing)

section: disagreeing-history
tags: [disagreeing-data, replacement-names, taxt-hist, slow]

description: >
  This script may or may not be up-to-date as we are migrating `Taxt` items to relational items.


  Only works with `tax/taxac` tags (that is, not protonym-based tags).


  May contain false positives (like replacement names that were later dropped).


  **ET homonym_replaced_by** = the "Homonym replaced by" of the **Extracted taxon**

related_scripts:
  - ReplacementNameForHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsMissing
