# frozen_string_literal: true

module DatabaseScripts
  class PointsToReplacementNameAndUsesRefTagAsAuthorCitation < DatabaseScript
    LIMIT = 100

    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "replacement name: {tax [0-9]+} {ref [0-9]+}").limit(LIMIT).includes(:taxon)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Converted to taxac', "Check usage", "Check replaced-by usage"
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          usage_string, matches = check_usage taxt
          replaced_by_usage_string, _replaced_by_matches = check_replaced_by_usage taxt, taxon

          converted_to_taxac = QuickAndDirtyFixes::ConvertTaxToTaxacTags[taxt]
          show_quick_fix_link = (converted_to_taxac != taxt) && matches

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],

            (quick_fix_link(history_item) if show_quick_fix_link),
            (show_quick_fix_link ? Detax[converted_to_taxac] : bold_warning('no changes and/or mismatch - must be updated manually')),

            usage_string,
            replaced_by_usage_string
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

      def check_replaced_by_usage taxt, taxon
        return [bold_warning('taxon has no homonym_replaced_by_id'), false] unless (replaced_by_id = taxon.homonym_replaced_by_id)

        tax_id = taxt[/replacement name: {tax [0-9]+}/i].scan(/\{tax ([0-9]+)\}/).flatten.first
        return [bold_warning('could not extract tax id'), false] unless tax_id

        if replaced_by_id == tax_id.to_i
          [bold_notice("tax_id and homonym_replaced_by_id matches! (#{replaced_by_id})"), true]
        else
          [bold_warning("tax_id and homonym_replaced_by_id do NOT match! (tax_id: #{tax_id}; replaced_by_id: #{replaced_by_id})"), false]
        end
      end

      def quick_fix_link history_item
        link_to 'Convert to taxac!', convert_to_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: Points to replacement name and uses <code>ref</code> tag as author citation

section: main
category: Taxt
tags: [has-quick-fix, new!]

issue_description:

description: >
  Note: Pages cannot be removed at the same time as converting to `taxac` tags, see %dbscript:HistoryItemsWithRefTagsAsAuthorCitations


  **Check replaced-by usage**


  * `tax_id` is extracted from this part of the history item: `replacement name: {tax ID}`.

  * `homonym_replaced_by_id` from the owner of the history item

  * Warnings in this columns do not block the quick-button (since it would block fixes for incorrect/unnecessary replacements).

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - PointsToReplacedNameAndUsesRefTagAsAuthorCitation
  - PointsToReplacementNameAndUsesRefTagAsAuthorCitation
  - TaxacTagsWithPageNumbers
