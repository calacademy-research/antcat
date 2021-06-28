# frozen_string_literal: true

module DatabaseScripts
  class NonRelationalFormDescriptionsHistoryItems < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.taxts_only.
        where(<<~SQL.squish).limit(LIMIT)
          taxt REGEXP '^{ref [0-9]+}: [0-9]+ \\\\(.+'
          OR
          taxt REGEXP '^{ref [0-9]+}: [0-9]+, [0-9]+ \\\\(.+'
          OR
          taxt REGEXP '^{ref [0-9]+}: [clxvi]+ \\\\(.+'
          OR
          taxt REGEXP '^{ref [0-9]+}: .{2,10} \\\\(.+'
        SQL
    end

    def render
      as_table do |t|
        t.header 'History item', 'Protonym/TT', 'taxt', 'Standard-ish?'
        t.rows do |history_item|
          [
            link_to(history_item.id, history_item_path(history_item)),
            protonym_link_with_terminal_taxa(history_item.protonym),
            history_item.to_taxt,
            (history_item.standard_format? ? 'Yes' : 'No')
          ]
        end
      end
    end
  end
end

__END__

title: Non-relational <code>FormDescriptions</code> history items

section: research
tags: [taxt-hist, future]

description: >
  Matches taxt items with format `ref + pages-ish + (`, which will return some false/true positives/negatives.

related_scripts:
  - FormDescriptionsHistoryItemsWithNonStandardForms
  - NonRelationalFormDescriptionsHistoryItems
