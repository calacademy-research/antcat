# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameForHistoryItemsMissing < DatabaseScript
    LIMIT = 500

    def results
      Taxon.joins(:replacement_name_for).
        joins(<<~SQL.squish).where("history_items.id IS NULL").limit(LIMIT)
          LEFT OUTER JOIN protonyms ON protonyms.id = taxa.protonym_id
          LEFT OUTER JOIN history_items ON history_items.protonym_id = protonyms.id AND
            (
              (history_items.taxt LIKE 'Replacement name for %')
              OR
              (history_items.type = 'ReplacementNameFor')
            )
        SQL
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            protonym_link(taxon.protonym)
          ]
        end
      end
    end
  end
end

__END__

title: >
  'Replacement name for' history items (missing)

section: disagreeing-history
tags: [disagreeing-data, replacement-names, rel-hist, taxt-hist, new!]

description: >
  Triggers for taxa that are set as the `taxa.homonym_replaced_by_id` of other taxa unless their protonym has
  a `ReplacementNameFor` history item (or a 'Replacement name for: ' `Taxt` history item).


  Most items are not really missing, but formatted differently.

related_scripts:
  - ReplacementNameForHistoryItemsDisagreeing
  - ReplacementNameForHistoryItemsMissing
  - ReplacementNameHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsMissing
