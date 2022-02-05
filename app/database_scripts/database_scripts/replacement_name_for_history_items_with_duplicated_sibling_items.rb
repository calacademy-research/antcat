# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameForHistoryItemsWithDuplicatedSiblingItems < DatabaseScript
    def results
      with_dups = HistoryItem.group(:protonym_id).having("COUNT(id) > 1").
        where("taxt REGEXP '^.?Junior (secondary |primary )?homonym' OR taxt LIKE 'Replacement name for%'")
      HistoryItem.where(protonym_id: with_dups.select(:protonym_id)).where("taxt LIKE ?", 'Replacement name for%')
    end

    def render
      as_table do |t|
        t.header 'Protonym/TT', 'Own Rep.name.for.', 'Own Jun.hom.of.',
          'Proper Jun.hom.of.', 'Identical?', 'Proper owner'
        t.rows do |rep_name_for_item|
          own_homonym_of_item = rep_name_for_item.protonym.history_items.
            find_by("taxt REGEXP '^.?Junior (secondary |primary )?homonym'")

          proper_owner_id = rep_name_for_item.ids_from_taxon_tags.first
          proper_owner = Taxon.find_by(id: proper_owner_id)
          proper_homonym_of_item = if proper_owner
                                     proper_owner.protonym.history_items.find_by("taxt REGEXP '^.?Junior (secondary |primary )?homonym'")
                                   end

          identical = identical? own_homonym_of_item, proper_homonym_of_item
          show_delete_non_identical_link = own_homonym_of_item && proper_homonym_of_item && !identical

          [
            protonym_link_with_terminal_taxa(rep_name_for_item.protonym),
            history_item_link_and_taxt(rep_name_for_item),
            (history_item_link_and_taxt(own_homonym_of_item) << (show_delete_non_identical_link ? delete_non_identical_link(own_homonym_of_item) : '')),
            history_item_link_and_taxt(proper_homonym_of_item),
            (identical ? delete_identical_link(own_homonym_of_item) : bold_warning('No')),
            taxon_link(proper_owner)
          ]
        end
      end
    end

    private

      def identical? own_homonym_of_item, proper_homonym_of_item
        return false unless own_homonym_of_item && proper_homonym_of_item
        normalize_taxt(own_homonym_of_item.taxt) == normalize_taxt(proper_homonym_of_item.taxt)
      end

      def normalize_taxt taxt
        taxt.delete_prefix('[').delete_suffix(']').delete_suffix('.')
      end

      def delete_identical_link own_homonym_of_item
        link = delete_history_item_quick_and_dirty_fix_path(
          history_item_id: own_homonym_of_item.id,
          edit_summary: "Delete identical duplicate of other 'Junior homonym of item'"
        )
        link_to 'Yes! Delete duplicate!', link, method: :post, remote: true, class: 'btn-normal btn-tiny'
      end

      def delete_non_identical_link own_homonym_of_item
        link = delete_history_item_quick_and_dirty_fix_path(
          history_item_id: own_homonym_of_item.id,
          edit_summary: "Delete duplicate-ish of other 'Junior homonym of item'"
        )
        link_to 'Delete this one!', link, method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: >
  'Replacement name for' history items with duplicated sibling items

section: pa-action-required
tags: [taxt-hist, replacement-names, very-slow, has-quick-fix]

description: >
  **Example**

  As of writing, these two items exists for {taxac 450605} (a replacement name):


  * #1: Replacement name for {taxac 450722}

  * #2: [Junior primary homonym of {taxac 450721}.]


  And this item exists for {taxac 450722} (a replaced homonym):


  * #3: [Junior primary homonym of {taxac 450721}.]


  Items **#2** and **#3** are duplicates, and it's **#2** that we want to delete
  because it does not refer to its owner.


  The previous recommendation was to merge **#1** and **#2** to make it read like this:


  * Replacement name for {taxac 450722}. [Junior primary homonym of {taxac 450721}.]


  But the merged item would still contain the same duplication (which we now
  are able to generate for display-purposes using relational history items).

related_scripts:
  - ReplacementNameForHistoryItemsWithDuplicatedForeignData
  - ReplacementNameForHistoryItemsWithDuplicatedSiblingItems
