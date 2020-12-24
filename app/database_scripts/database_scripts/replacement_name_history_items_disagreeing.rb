# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameHistoryItemsDisagreeing < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      HistoryItem.taxts_only.where("history_items.taxt LIKE 'Replacement name: {tax%'")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym', 'Terminal taxon',
          'taxt',
          'Extracted taxon',
          'P / ETP author', 'Diff. key?', 'Diff. ref?',
          'PTT homonym_replaced_by',
          'ET = TT.HRP?'

        t.rows do |history_item|
          taxt = history_item.taxt
          extracted_taxon = Taxon.find(history_item.ids_from_taxon_tags.first)

          same = extracted_taxon == history_item.terminal_taxon.homonym_replaced_by

          protonym = history_item.protonym

          protonym_author_citation = protonym.author_citation
          extracted_taxon_protonym_author_citation = extracted_taxon.protonym.author_citation
          different_author_citation = protonym_author_citation != extracted_taxon_protonym_author_citation
          different_author_reference = protonym.authorship_reference != extracted_taxon.protonym.authorship_reference

          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link(history_item.protonym),
            taxon_link(history_item.terminal_taxon),

            taxt,
            taxon_link(extracted_taxon),

            "#{protonym_author_citation}<br>#{extracted_taxon_protonym_author_citation}",
            (different_author_citation ? 'Yes' : bold_warning('No')),
            (different_author_reference ? 'Yes' : bold_warning('No')),

            taxon_link(history_item.terminal_taxon.homonym_replaced_by),
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
tags: [slow]

description: >
  This script may or may not be up-to-date as we are migrating `Taxt` items to relational items.


  Only works with `tax/taxac` tags (that is, not protonym-based tags).


  May contain false positives (like replacement names that were later dropped).


  Script column | Description

  --- | ---

  **P / ETP author** | Author citation of Protonym and Extracted Taxon Protonym

  **Diff. key?** | Yes = author citations are the same (same letters and years)

  **Diff. ref?** | Yes = author citations are the same (same reference ID)

  **PTT homonym_replaced_by** | the "Homonym replaced by" of the Terminal Taxon of the protonym of **Extracted taxon**

  **ET = PTT.HRB** | Extracted Taxon = PTT homonym_replaced_by**

related_scripts:
  - ReplacementNameForHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsMissing
