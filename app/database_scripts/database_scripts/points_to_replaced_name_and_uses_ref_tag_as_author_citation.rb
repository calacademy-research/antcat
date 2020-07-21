# frozen_string_literal: true

module DatabaseScripts
  class PointsToReplacedNameAndUsesRefTagAsAuthorCitation < DatabaseScript
    LIMIT = 100

    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "replacement name for {tax [0-9]+} {ref [0-9]+}").limit(LIMIT).includes(:taxon)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Quick fix', 'Converted to taxac',
          "Check usage", "Check replaced-by usage", 'Switch tax quick-fix'
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
            replaced_by_usage_string,
            (check_switch_tax_quick_fix_link(history_item) unless matches)
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
        unless (replaced_by_id = Taxon.find_by(homonym_replaced_by_id: taxon.id)&.id)
          return [gray_notice('found no taxon with a homonym_replaced_by_id pointing to taxon (ok for unnecessary replacements'), false]
        end

        tax_id = taxt[/replacement name for {tax [0-9]+}/i].scan(/\{tax ([0-9]+)\}/).flatten.first
        return [bold_warning('count not extract tax id'), false] unless tax_id

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

      def check_switch_tax_quick_fix_link history_item
        taxt = history_item.taxt
        ids = taxt.scan(/\{tax (?<tax_id>[0-9]+)\} \{ref (?<ref_id>[0-9]+)\}/)

        if ids.size != 1
          bold_warning("contains more than one tax tag, must be fixed manually")
        else
          extracted_tax_id = ids.first.first
          extracted_ref_id = ids.first.last

          mentioned_taxon = Taxon.find(extracted_tax_id)
          same_named_taxa = Taxon.where(name_cache: mentioned_taxon.name_cache).where.not(id: mentioned_taxon.id)
          case same_named_taxa.size
          when 0
            bold_notice "found no other taxa with the same name (#{mentioned_taxon.name_cache})"
          when 1
            new_taxon = same_named_taxa.first
            switch_tax_quick_fix_link history_item, new_taxon, mentioned_taxon, extracted_ref_id
          else
            bold_warning "found more than one taxon with the same name (#{mentioned_taxon.name_cache})"
          end
        end
      end

      def switch_tax_quick_fix_link history_item, new_taxon, mentioned_taxon, extracted_ref_id
        url = switch_tax_tag_quick_and_dirty_fix_path(
          taxon_history_item_id: history_item.id,
          replace_tax_id: mentioned_taxon.id,
          new_tax_id: new_taxon.id
        )
        link = link_to "Switch to this tax tag!", url, method: :post, remote: true, class: 'btn-warning btn-tiny'

        ref_tag_matches = new_taxon.authorship_reference.id == extracted_ref_id.to_i
        ref_tag_notice = ref_tag_matches ? bold_notice('ref tag matches!') : bold_warning('ref does NOT match!')

        CatalogFormatter.link_to_taxon(new_taxon) + " #{new_taxon.author_citation} #{ref_tag_notice}".html_safe + link
      end
  end
end

__END__

title: Points to replaced name and uses <code>ref</code> tag as author citation

section: regression-test
category: Taxt
tags: [has-quick-fix]

issue_description:

description: >
  Note: Pages cannot be removed at the same time as converting to `taxac` tags, see %dbscript:HistoryItemsWithRefTagsAsAuthorCitations


  **Check replaced-by usage**


  * `tax_id` is extracted from this part of the history item: `replacement name for {tax ID}`.

  * `homonym_replaced_by_id` is a `Taxon` ID of a record where `homonym_replaced_by_id` is the same as the owner of the history item

  * Warnings in this columns do not block the quick-button (since it would block fixes for incorrect/unnecessary replacements).


  **Switch tax quick-fix:**

  Quick-fix link for switching to the suggested `tax` ID for items that cannot be fixed with the normal button.
  Use this button if the `ref` tag is correct, but the `tax` tag links an incorrect taxon (most probably, either the `tax` tag, or the replacment,
  is a homonym). The same item will appear in this script again after reloading the page,
  and hopefylly it can be converted to a `taxac` tag this time.


  For cases like "found more than one taxon with the same name (Pachycondyla striata)": To see which, find the taxon link
  ("Pachycondyla striata") in the same row, open the catalog page, and there will be a blue box for "Taxa with same name".

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - PointsToReplacedNameAndUsesRefTagAsAuthorCitation
  - PointsToReplacementNameAndUsesRefTagAsAuthorCitation
  - TaxacTagsWithPageNumbers
