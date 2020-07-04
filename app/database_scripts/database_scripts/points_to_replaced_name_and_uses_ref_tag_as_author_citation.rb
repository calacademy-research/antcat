# frozen_string_literal: true

module DatabaseScripts
  class PointsToReplacedNameAndUsesRefTagAsAuthorCitation < DatabaseScript
    LIMIT = 100

    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "replacement name for {tax [0-9]+} {ref [0-9]+}").limit(LIMIT).includes(:taxon)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first 100)<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Converted to taxac', "Check usage"
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          usage_string, matches = check_usage taxt

          converted_to_taxac = QuickAndDirtyFixes::ConvertTaxToTaxacTags[taxt]
          show_quick_fix_link = (converted_to_taxac != taxt) && matches

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
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

        ids = taxt.scan(/\{tax (?<tax_id>[0-9]+\}) \{ref (?<ref_id>[0-9]+)\}/)

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
        link_to 'Convert to taxac!', convert_to_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: Points to replaced name and uses <code>ref</code> tag as author citation

section: main
category: Taxt
tags: [has-quick-fix, new!]

issue_description:

description: >
  Note: Pages cannot be removed at the same time as converting to `taxac` tags, see %dbscript:HistoryItemsWithRefTagsAsAuthorCitations

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - PointsToReplacedNameAndUsesRefTagAsAuthorCitation
  - PointsToReplacementNameAndUsesRefTagAsAuthorCitation
  - TaxacTagsWithPageNumbers
