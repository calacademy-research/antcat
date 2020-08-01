# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithMissingTagsFirstAvailableUseOf < DatabaseScript
    LIMIT = 150

    AS_OBSOLETE_COMBINATION = QuickAdd::FromHardcodedInfrasubspeciesName::AS_OBSOLETE_COMBINATION
    AS_UNAVAILABLE = QuickAdd::FromHardcodedInfrasubspeciesName::AS_UNAVAILABLE

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      TaxonHistoryItem.where('taxt REGEXP ?', "^\\[First available use of #{Taxt::MISSING_TAG_START}2").limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Hardcoded names', 'Highlighted taxt',
          'Preview quick-fix', 'Quick-fix button',
          'Quick-add button', 'Quick-add attributes'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          helper = QuickAndDirtyFixes::ReplaceMissingTags.new(taxt)

          normalized_names = taxt.scan(Taxt::MISSING_TAG_REGEX).flatten.map do |hardcoded_name|
            hardcoded_name.gsub(%r{</?i>}, '')
          end
          normalized_name = normalized_names.first
          quick_adder = QuickAdd::FromHardcodedInfrasubspeciesName.new(
            normalized_name, history_item: history_item
          )

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),

            format_hardcoded_names_with_taxa(helper.hardcoded_names_with_taxa).join('<br>'),

            Detax[highlight_taxt(taxt.dup)],
            Detax[helper.call],
            (replace_missing_tags_link(history_item, helper.target_for_replacement[:normalized_name]) if helper.can_be_quick_fixed?),
            (quick_add_links(quick_adder) if quick_adder.can_add?),
            quick_adder&.synopsis
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

      def quick_add_links quick_adder
        [
          new_obsolete_combination_link(quick_adder),
          new_unavailable_taxon_link(quick_adder)
        ].join('<br><br>')
      end

      def new_obsolete_combination_link quick_adder
        label = "Add as obsolete combination"
        link = link_to label, new_taxa_path(quick_adder.taxon_form_params(AS_OBSOLETE_COMBINATION)), class: "btn-tiny btn-normal"
        link + " <small>(what's in Quick-add attributes)</small>".html_safe
      end

      def new_unavailable_taxon_link quick_adder
        label = "Add as unavailable"
        link = link_to label, new_taxa_path(quick_adder.taxon_form_params(AS_UNAVAILABLE)), class: "btn-tiny btn-normal"
        link + " <small>(Quick-add attributes, but unavailable status and no current_taxon)</small>".html_safe
      end
  end
end

__END__

title: History items with <code>missing</code> tags (first available use of)

section: missing-tags
category: Taxt
tags: [has-quick-fix, slow-render]

issue_description:

description: >
  Script for replacing "first available use of"-`missing` tags, or quick-adding new taxa
  in case there are no matches for the `missing` name.

related_scripts:
  - HistoryItemsWithMissingTagsFirstAvailableUseOf
