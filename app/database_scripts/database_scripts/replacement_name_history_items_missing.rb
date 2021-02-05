# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameHistoryItemsMissing < DatabaseScript
    LIMIT = 500

    def results
      Taxon.homonyms.
        joins(<<~SQL.squish).where("history_items.id IS NULL").limit(LIMIT)
          LEFT OUTER JOIN protonyms ON protonyms.id = taxa.protonym_id
          LEFT OUTER JOIN history_items ON history_items.protonym_id = protonyms.id AND
            (
              (history_items.taxt LIKE 'Replacement name: %')
              OR
              (history_items.type = 'ReplacementName')
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
  'Replacement name' history items (missing)

section: disagreeing-history
category: History
tags: []

description: >

related_scripts:
  - ReplacementNameForHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsDisagreeing
  - ReplacementNameHistoryItemsMissing
