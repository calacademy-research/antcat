# frozen_string_literal: true

module DatabaseScripts
  class TaxacTagsWithPageNumbers < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "{taxac [0-9]+}: [0-9]")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt', 'Remove pages!', 'With pages removed'
        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          without_pages = QuickAndDirtyFixes::RemovePagesFromTaxacTags[taxt]
          show_quick_fix_link = without_pages != taxt

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            (quick_fix_link(history_item) if show_quick_fix_link),
            (show_quick_fix_link ? Detax[without_pages] : bold_warning('no changes - must be updated manually'))
          ]
        end
      end
    end

    private

      def quick_fix_link history_item
        link_to 'Remove pages!', remove_pages_from_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: <code>taxac</code> tags with page numbers

section: main
category: Taxt
tags: [has-quick-fix]

description: >
  `taxac` tags should be used for disambiguation purposes only, so no pages should appear after the tag.


  "Taxonomic claims" should include pages -- for these we still use `ref` tags + pages in plaintext.


  **Example**


  * {taxac 429366} junior homonym and junior synonym of {taxac 429365}: {ref 133029}: 451.


  In the above example, "{ref 133029}: 451" is the only litterature citation, while `taxac`
  tags are used instead of `tax` tags for disambiguation purposes.

related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - TaxacTagsWithPageNumbers
