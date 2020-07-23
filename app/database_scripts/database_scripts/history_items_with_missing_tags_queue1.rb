# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithMissingTagsQueue1 < DatabaseScript
    LIMIT = 250

    def results
      TaxonHistoryItem.where('taxt LIKE ?', "%#{Taxt::MISSING_TAG_START}%").limit(LIMIT)
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
        possible_subspecies_instead_of_species(normalized_name).map do |taxon|
          replace_with_alt_tax_link(history_item, normalized_name, taxon)
        end.join("<br><br>")
      end

      def possible_subspecies_instead_of_species normalized_name
        name_parts = normalized_name.split
        return [] unless name_parts.size == 2

        genus_name, epithet = name_parts
        Subspecies.joins(:name).
          where("names.name LIKE ?", "#{genus_name} %").
          where("names.epithet LIKE ?", "#{epithet[0..3]}%")
      end

      def replace_with_alt_tax_link history_item, normalized_name, replace_with_taxon
        epithet = normalized_name.split.last
        alt_tax_help_text = if epithet == replace_with_taxon.name.epithet
                              bold_notice "[different rank; same epithet]"
                            else
                              bold_warning "[different rank; epithet not same, but similar]"
                            end
        alt_tax_help_text += bold_warning(" [IS SAME AS TAXON OF HISTORY ITEM]") if history_item.taxon_id == replace_with_taxon.id
        alt_tax_help_text += purple_notice(" [has history item taxon as current_taxon]") if history_item.taxon_id == replace_with_taxon&.current_taxon&.id
        alt_tax_help_text += gray_notice(" [is current_taxon of history item taxon]") if history_item.taxon.current_taxon&.id == replace_with_taxon.id

        label = "Replace with <i>#{replace_with_taxon.name.short_name}</i>".html_safe
        url = replace_missing_tag_with_tax_tag_quick_and_dirty_fix_path(
          taxon_history_item_id: history_item.id,
          hardcoded_missing_name: normalized_name,
          replace_with_taxon_id: replace_with_taxon.id
        )
        link = link_to label, url, method: :post, remote: true, class: 'btn-warning btn-tiny'

        alt_tax_help_text + replace_with_taxon.decorate.link_to_taxon_with_author_citation + link
      end
  end
end

__END__

title: History items with <code>missing</code> tags (queue 1)

section: main
category: Taxt
tags: [has-quick-fix, slow-render]

issue_description:

description: >
  The quick-fix button replaces one `missing` tag at a time - if the first `missing` tag cannot be
  replaced (due to <span class="bold-warning">no matches</span> or <span class="bold-warning">multiple matches</span>),
  then the button cannot be used for <span class="bold-notice">convertable</span> tags until the first tag has been fixed.


  **Alt. replacement**

  <span class="bold-warning">Warning:</span> Use with care. It searches for existing subspecies like this:


  * `{missing Acanthostichus obscuridens}` --> `Acanthostichus ANYTHING obscXXX` --> {tax 430258}


  How often it's correct will vary based on the current batch of this script.


  <span class="bold-notice">[same epithet]</span> means that the protonym of the suggested replacement is probably correct, but
  beware of homonys, and the `tax` tag refers to a ssubspecies, which is not always correct.


  I cross-checked a bunch of species/subspecies with AntCat history items and data from AntWiki.
  Many have indeed at some point been species (which means we are missing a species record for it and the alt. replacement is not correct),
  while other do not mention any such combination (which may simply mean that the data is not complete in AntCat/AntWiki).


  More information here: %wiki6 and %github1052

related_scripts:
  - HistoryItemsWithMissingTagsQueue1
  - HistoryItemsWithMissingTagsQueue2
  - MissingTaxaToBeCreated
