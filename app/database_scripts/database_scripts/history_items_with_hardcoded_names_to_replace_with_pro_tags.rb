# frozen_string_literal: true

module DatabaseScripts
  class HistoryItemsWithHardcodedNamesToReplaceWithProTags < DatabaseScript
    LIMIT = 75

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      TaxonHistoryItem.
        joins(protonym: :name).
        where("taxt REGEXP CONCAT('^', names.name, ' ')").
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'taxt', 'Preview quick-fix', 'Quick-fix button'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          helper = QuickAndDirtyFixes::HardcodedNameToProTag.new(history_item)

          [
            quick_fix_link(history_item),

            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),

            Detax[taxt],
            Detax[helper.call]
          ]
        end
      end
    end

    private

      def quick_fix_link history_item
        link_to "Replace with pro tag!", replace_with_pro_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: History items with hardcoded names to replace with <code>pro</code> tags

section: regression-test
category: Taxt
tags: [has-quick-fix]

issue_description:

description: >
  Use the quick-button to replace the hardcoded name (it's the first thing in the content) with a `pro` tag, where the
  ID will be that of the taxon's protonym.

related_scripts:
  - HistoryItemsWithHardcodedNamesToReplaceWithProTags
