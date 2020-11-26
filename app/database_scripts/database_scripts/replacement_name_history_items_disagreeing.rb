# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameHistoryItemsDisagreeing < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      HistoryItem.where("history_items.taxt LIKE 'Replacement name: {tax%'")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Terminal taxon', 'taxt', 'Extracted taxon', 'PTT homonym_replaced_by', 'OK?'
        t.rows do |history_item|
          taxt = history_item.taxt
          extracted_taxon = Taxon.find(history_item.ids_from_tax_or_taxac_tags.first)

          same = extracted_taxon == history_item.current_taxon_owner.homonym_replaced_by

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxon_link(history_item.terminal_taxon),
            taxt,
            taxon_link(extracted_taxon),
            taxon_link(history_item.current_taxon_owner.homonym_replaced_by),
            (same ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

title: >
  'Replacement name:' history items (disagreeing)

section: disagreeing-history
category: History
tags: [slow, new!]

description: >
  Only works with `tax/taxac` tags (that is, not protonym-based tags).


  May contain false positives (like replacement names that were later dropped).


  **PTT homonym_replaced_by** = the "Homonym replaced by" of the terminal taxon of the protonym of **Extracted taxon**

related_scripts:
  - ReplacementNameForHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsMissing
