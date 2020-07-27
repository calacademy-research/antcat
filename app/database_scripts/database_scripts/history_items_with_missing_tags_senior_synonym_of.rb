# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithMissingTagsSeniorSynonymOf < DatabaseScript
    LIMIT = 200

    def results
      TaxonHistoryItem.where('taxt REGEXP ?', "^Senior synonym of #{Taxt::MISSING_TAG_START}2").limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'Alt. replacement', 'History item', 'Taxon', 'Hardcoded names', 'Highlighted taxt', 'Preview quick-fix', 'Quick-fix button'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          helper = QuickAndDirtyFixes::ReplaceMissingTags.new(taxt)

          [
            replace_with_alt_tax_links(history_item, helper).presence || "-",

            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),

            format_hardcoded_names_with_taxa(helper.hardcoded_names_with_taxa).join('<br>'),

            Detax[highlight_taxt(taxt.dup)],
            Detax[helper.call],
            (replace_missing_tags_link(history_item, helper.target_for_replacement[:normalized_name]) if helper.can_be_quick_fixed?)
          ]
        end
      end
    end

    private

      def replace_missing_tags_link history_item, normalized_name
        link_to "Replace #{normalized_name}!", replace_missing_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end

      def format_hardcoded_names_with_taxa hardcoded_names_with_taxa
        hardcoded_names_with_taxa.map do |item|
          taxa = item[:taxa]

          message = case taxa.size
                    when 0 then bold_warning('no matches')
                    when 1 then bold_notice('convertable')
                    else bold_warning('multiple matches')
                    end

          "#{item[:normalized_name]}<br>#{message}<br> #{taxon_links(taxa)}<br><br>"
        end
      end

      def highlight_taxt taxt
        taxt.gsub!(Taxt::MISSING_TAG_REGEX) do
          bold_notice $LAST_MATCH_INFO[:hardcoded_name]
        end
      end

      # TODO: Get rid of all of this ASAP.
      def replace_with_alt_tax_links history_item, helper
        normalized_name = helper.target_for_replacement[:normalized_name]
        replace_with_possible_subspecies_instead_of_species_links history_item, normalized_name
      end

      def replace_with_possible_subspecies_instead_of_species_links history_item, normalized_name
        possible_subspecies_instead_of_species(normalized_name, history_item).map do |taxon|
          replace_with_alt_tax_link(history_item, normalized_name, taxon)
        end.join("<br><br>")
      end

      def possible_subspecies_instead_of_species normalized_name, history_item
        name_parts = normalized_name.split
        return [] unless name_parts.size == 2

        genus_name, epithet = name_parts
        Subspecies.joins(:name).
          where(current_taxon: history_item.taxon).
          where("names.name LIKE ?", "#{genus_name} %").
          where("names.epithet = ?", epithet)
      end

      def replace_with_alt_tax_link history_item, normalized_name, replace_with_taxon
        label = "Replace with <i>#{replace_with_taxon.name.short_name}</i>".html_safe
        url = replace_missing_tag_with_tax_tag_quick_and_dirty_fix_path(
          taxon_history_item_id: history_item.id,
          hardcoded_missing_name: normalized_name,
          replace_with_taxon_id: replace_with_taxon.id
        )
        link = link_to label, url, method: :post, remote: true, class: 'btn-warning btn-tiny'

        replace_with_taxon.decorate.link_to_taxon_with_author_citation + "<br>".html_safe + link
      end
  end
end

__END__

title: History items with <code>missing</code> tags (senior synonym of)

section: missing-tags
category: Taxt
tags: [has-quick-fix, slow-render]

issue_description:

description: >
  **Alt. replacement** offers an alternative `tax` ID to be used for the replacement when there is
  no `Taxon` record with exactly the same name as what's in the `missing` tag.


  For the current batch, it will always be a subspecies with the same genus and epithet, like this:



  * `{missing Acanthostichus obscuridens}` --> `Acanthostichus ANYTHING obscuridens` --> {tax 430258}


  And the `current_taxon` of the alt. replacement will always be the same as the owner of the
  history item (**Taxon** column).

related_scripts:
  - HistoryItemsWithMissingTagsJuniorSynonymOf
  - HistoryItemsWithMissingTagsSeniorSynonymOf
