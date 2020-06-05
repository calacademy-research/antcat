# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsStartingWithASelfTaxTag < DatabaseScript
    LIMIT = 200

    def results
      TaxonHistoryItem.
        where("taxt LIKE CONCAT('{tax ', CONVERT(taxon_id, char), '}%') COLLATE utf8_unicode_ci").
        limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Rank', 'Status', 'taxt', "Replace with pro tag?"
        t.rows do |history_item|
          taxon = history_item.taxon

          first_tax = history_item.taxt[/{tax \d+}/][/\d+/].to_i
          first_taxon = Taxon.find_by(id: first_tax)
          replace_with_pro_tag = first_taxon.name_cache == taxon.protonym.name.name

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.type,
            taxon.status,
            Detax[history_item.taxt],
            (replace_with_pro_tag ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end
  end
end

__END__

section: research
category: Taxt
tags: [slow-render]

issue_description:

description: >
  Where a "self-tax-tag" looks like this: `{tax <taxon_id of history item>}`.

related_scripts:
  - HistoryItemsStartingWithASelfTaxTag
