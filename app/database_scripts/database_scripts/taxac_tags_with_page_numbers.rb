# frozen_string_literal: true

module DatabaseScripts
  class TaxacTagsWithPageNumbers < DatabaseScript
    def results
      TaxonHistoryItem.where("taxt REGEXP ?", "{taxac [0-9]+}: [0-9]")
    end

    def render
      as_table do |t|
        t.header 'History item', 'Taxon', 'Status', 'taxt',
          'Remove pages!', 'With pages removed',
          'Force-remove pages!', 'With pages force-removed'

        t.rows do |history_item|
          taxt = history_item.taxt
          taxon = history_item.taxon

          without_pages = QuickAndDirtyFixes::RemovePagesFromTaxacTags[taxt]
          show_quick_fix_link = without_pages != taxt

          force_without_pages = show_quick_fix_link ? nil : QuickAndDirtyFixes::ForceRemovePagesFromTaxacTags[taxt]
          show_force_quick_fix_link = !show_quick_fix_link && (force_without_pages != taxt)

          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            taxon_link(taxon),
            taxon.status,
            Detax[taxt],
            (quick_fix_link(history_item) if show_quick_fix_link),
            without_pages_column(show_quick_fix_link, without_pages),
            (force_quick_fix_link(history_item) if show_force_quick_fix_link),
            force_without_pages_column(show_quick_fix_link, show_force_quick_fix_link, force_without_pages)
          ]
        end
      end
    end

    private

      def quick_fix_link history_item
        link_to 'Remove pages!', remove_pages_from_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-normal btn-tiny'
      end

      def force_quick_fix_link history_item
        link_to 'Force-remove pages!', force_remove_pages_from_taxac_tags_quick_and_dirty_fix_path(taxon_history_item_id: history_item.id),
          method: :post, remote: true, class: 'btn-warning btn-tiny'
      end

      def without_pages_column show_quick_fix_link, without_pages
        if show_quick_fix_link
          Detax[without_pages]
        else
          bold_warning('no changes - must be updated manually')
        end
      end

      def force_without_pages_column show_quick_fix_link, show_force_quick_fix_link, force_without_pages
        if show_quick_fix_link
          bold_notice('use the other button!')
        elsif show_force_quick_fix_link
          Detax[force_without_pages]
        else
          bold_warning('no changes - must be updated manually')
        end
      end
  end
end

__END__

title: <code>taxac</code> tags with page numbers

section: main
category: Taxt
tags: [has-quick-fix, updated!]

description: >
  `taxac` tags should be used for disambiguation purposes only, so no pages should appear after the tag.


  "Taxonomic claims" should include pages -- for these we still use `ref` tags + pages in plaintext.


  **Example**


  * {taxac 429366} junior homonym and junior synonym of {taxac 429365}: {ref 133029}: 451.


  In the above example, "{ref 133029}: 451" is the only litterature citation, while `taxac`
  tags are used instead of `tax` tags for disambiguation purposes.


  **Quick-fix buttons**


  The blue "Remove pages!" button is visible for `taxac` tags where the hardcoded pages are the same as the pages for
  the linked taxon's authorship (hover it).


  The red "Force-remove pages!" button is for cases where we want to remove hardcoded pages even when they
  are not the same as the linked taxon's authorship. It's usually because the authorship contains additional pages
  like "69 (footnote)" instead of just "69". Hover the linked taxon to confirm that's the case and that
  we want to remove the pages.


related_scripts:
  - HistoryItemsWithRefTagsAsAuthorCitations
  - HomonymsAsTaxTags
  - TaxacTagsWithPageNumbers
