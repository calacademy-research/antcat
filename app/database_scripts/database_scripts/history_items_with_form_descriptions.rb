# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithFormDescriptions < DatabaseScript
    def results
      TaxonHistoryItem.where(TaxonHistoryItem::VHIC_FORM_DESCRIPTION).includes(:taxon).limit(200)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(taxon),
            taxon.status,
            Detax[taxt]
          ]
        end
      end
    end
  end
end

__END__

section: list
category: Taxt2
tags: []

description: >
  WIP. Issue: %github841


  Showing first 200.


  This script can be ignored for now. It was added for investigating how to normalize form descriptions in history items.


  * [All form descriptions](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5E%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B+%5C%28&)

  * [Single ref + single form](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5E%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B+%5C%28%5Bwqmlks%5D%5C.%5C%29%24)


  Probably fix these first:


  * ["Description of queen"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Description+of+queen)

  * ["Description of gyne"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Description+of+gyne)

  * "Description (m.q.)"

  * ["Lectotype designation"](/taxon_history_items?utf8=✓&search_type=&q=Lectotype+designation)

  * ["ref + designation"](/taxon_history_items?utf8=%E2%9C%93&search_type=REGEXP&q=%5E%7Bref+%5B0-9%5D%2B%7D%3A+%5B0-9%5D%2B+%5C%28.*%2F%3Fdesignation)

  * ["Designation of neotype"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Designation+of+neotype)

  * ["Redescription"](/taxon_history_items?utf8=%E2%9C%93&search_type=&q=Redescription)
