# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithMissingTags < DatabaseScript
    def results
      TaxonHistoryItem.where('taxt LIKE ?', "%#{Taxt::MISSING_TAG_START}%")
    end

    def statistics
      most_missing_names = missing_names_by_count.take(15).map do |normalized_name, count|
        "#{normalized_name}: #{count}"
      end.join('<br>')

      <<~RESULTS.html_safe
        Results: #{results.count}<br>
        <br>

        <b>Most missing (first 15 of #{missing_names_by_count.size} unique names):</b><br>
        #{most_missing_names}
      RESULTS
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Hardcoded names', 'Highlighted taxt', 'Preview quick-fix', 'Quick-fix button'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          helper = QuickAndDirtyFixes::ReplaceMissingTags.new(taxt)

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),

            format_hardcoded_names_with_taxa(helper.hardcoded_names_with_taxa).join('<br>'),

            Detax[highlight_taxt(taxt.dup)],
            Detax[helper.call],
            (quick_fix_link(history_item, helper.target_for_replacement[:normalized_name]) if helper.can_be_quick_fixed?)
          ]
        end
      end
    end

    private

      def missing_names_by_count
        @_missing_names_by_count = begin
          all_hardcoded_taxts = results.pluck(:taxt).join
          all_hardcoded_names = all_hardcoded_taxts.scan(Taxt::MISSING_TAG_REGEX).flatten.map do |hardcoded_name|
            Unitalicize[hardcoded_name.html_safe]
          end

          tally = all_hardcoded_names.each_with_object(Hash.new(0)) do |normalized_name, hsh|
            hsh[normalized_name] += 1
          end

          tally.sort_by(&:second).reverse
        end
      end

      def quick_fix_link history_item, normalized_name
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

          "#{item[:normalized_name]}<br>#{message}<br> #{taxa_list(taxa)}<br><br>"
        end
      end

      def highlight_taxt taxt
        taxt.gsub!(Taxt::MISSING_TAG_REGEX) do
          bold_notice $LAST_MATCH_INFO[:hardcoded_name]
        end
      end
  end
end

__END__

title: History items with <code>missing</code> tags

section: main
category: Taxt
tags: [has-quick-fix, slow-render]

issue_description:

description: >
  The quick-fix button replaces one `missing` tag at a time - if the first `missing` tag cannot be
  replaced (due to <span class="bold-warning">no matches</span> or <span class="bold-warning">multiple matches</span>),
  then the button cannot be used for <span class="bold-notice">convertable</span> tags until the first tag has been fixed.


  More information here: %wiki6 and %github1052

related_scripts:
  - HistoryItemsWithMissingTags
  - MissingTaxaToBeCreated
