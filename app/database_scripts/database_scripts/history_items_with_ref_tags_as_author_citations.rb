# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithRefTagsAsAuthorCitations < DatabaseScript
    LIMIT = 100

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      HistoryItem.taxts_only.
        where("taxt REGEXP ?", "{#{Taxt::TAX_TAG} [0-9]+} {#{Taxt::REF_TAG} [0-9]+}").
        where.not("taxt LIKE ?", "%nomen nudum%").
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Converted to taxac', "Check usage"
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.terminal_taxon

          usage_string, matches = check_usage taxt

          converted_to_taxac = QuickAndDirtyFixes::ConvertTaxToTaxacTags[taxt]
          show_quick_fix_link = (converted_to_taxac != taxt) && matches

          [
            link_to(history_item.id, history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],

            (quick_fix_link(history_item) if show_quick_fix_link),
            (show_quick_fix_link ? Detax[converted_to_taxac] : bold_warning('no changes and/or mismatch - must be updated manually')),

            usage_string
          ]
        end
      end
    end

    private

      def check_usage taxt
        matches = true

        ids = taxt.scan(/\{#{Taxt::TAX_TAG} (?<tax_id>[0-9]+\}) \{#{Taxt::REF_TAG} (?<ref_id>[0-9]+)\}/o)

        string = +''
        ids.each do |(tax_id, ref_id)|
          taxon = Taxon.find(tax_id)
          reference = Reference.find(ref_id)

          string << CatalogFormatter.link_to_taxon(taxon)
          string << ' '
          string << if taxon.authorship_reference == reference
                      'tax/ref matches'
                    else
                      matches = false
                      bold_warning('tax/ref do not match')
                    end
          string << '<br><br>'
        end
        [string, matches]
      end

      def quick_fix_link history_item
        link_to 'Convert to taxac!', convert_to_taxac_tags_quick_and_dirty_fix_path(history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-danger'
      end
  end
end

__END__

title: History items with <code>ref</code> tags as author citations

section: regression-test
tags: [taxt-hist, has-quick-fix]

description: >
  The current batch mainly contains false positives due to how we format *nomina nuda* and some unavailable names.


  **Note that "tax/ref matches" in the "Check usage" column just means that the ID for `ref` tag
  is the same as the reference ID of the taxon's protonym -- both may be incorrect.**


  Use the "Convert to taxac!" button to quickly replace all `tax` + `ref` tag combinations
  for a history item with a `taxac` tag for the taxon. Refresh the page to get rid cleaned items.
  The link is only visible if the tags match, but like mentioned above, they may match but both may be incorrect.


  Page numbers are not removed when using the quick-fix button;
  they can be removed with the quick-fix button in %dbscript:TaxacTagsWithPageNumbers

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - TaxacTagsWithPageNumbers
