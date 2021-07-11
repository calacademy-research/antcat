# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNameForHistoryItemsWithDuplicatedForeignData < DatabaseScript
    def results
      HistoryItem.where("taxt REGEXP ?", "^Replacement name for {(taxac|prottac) [0-9]+}.+junior")
    end

    def render
      as_table do |t|
        t.header 'Protonym/TT', 'Own Rep.name.for.', 'Own Jun.hom.of. part',
          'Proper Jun.hom.of. part', 'Proper Jun.hom.of.', 'Identical?', 'Proper owner'
        t.rows do |rep_name_for_item|
          rep_name_for_taxt = rep_name_for_item.to_taxt
          own_homonym_of_taxt = rep_name_for_taxt.gsub(/^Replacement name for {(taxac|prottac) [0-9]+}/, '')
          own_homonym_of_taxt = normalize_taxt(own_homonym_of_taxt)

          proper_owner_id = rep_name_for_item.ids_from_taxon_tags.first
          proper_owner = Taxon.find_by(id: proper_owner_id)
          proper_homonym_of_item = if proper_owner
                                     proper_owner.protonym.history_items.find_by("taxt REGEXP '^.?Junior (secondary |primary )?homonym'")
                                   end
          proper_homonym_of_taxt = proper_homonym_of_item ? normalize_taxt(proper_homonym_of_item.taxt) : ''

          identical = own_homonym_of_taxt.downcase == proper_homonym_of_taxt.downcase

          show_strip_non_identical_link = proper_homonym_of_item && !identical

          [
            protonym_link_with_terminal_taxa(rep_name_for_item.protonym),
            history_item_link_and_taxt(rep_name_for_item) << (show_strip_non_identical_link ? strip_non_identical_link(rep_name_for_item) : ''),
            own_homonym_of_taxt,
            proper_homonym_of_taxt,
            history_item_link_and_taxt(proper_homonym_of_item),
            (identical ? strip_identical_link(rep_name_for_item) : ''),
            taxon_link(proper_owner)
          ]
        end
      end
    end

    private

      def normalize_taxt taxt
        taxt.gsub(/^[\[ .(;]+/, '').gsub(/[ .)\]]+$/, '').delete_prefix(', a ')
      end

      def strip_identical_link rep_name_for_item
        link = strip_except_replacement_name_for_quick_and_dirty_fix_path(
          history_item_id: rep_name_for_item.id,
          edit_summary: "strip identical duplicate data of other 'Junior homonym of item'"
        )
        link_to 'Yes! Strip identical data!', link, method: :post, remote: true, class: 'btn-normal btn-tiny'
      end

      def strip_non_identical_link rep_name_for_item
        link = strip_except_replacement_name_for_quick_and_dirty_fix_path(
          history_item_id: rep_name_for_item.id,
          edit_summary: "strip foreign/duplicate-ish data of other 'Junior homonym of item'"
        )
        link_to "Strip after 'Replacement name for TAG ID'", link, method: :post, remote: true, class: 'btn-warning btn-tiny'
      end
  end
end

__END__

title: >
  'Replacement name for' history items with duplicated foreign data

section: pa-action-required
tags: [taxt-hist, replacement-names, very-slow, new!, has-quick-fix]

description: >
  Like %dbscript:ReplacementNameForHistoryItemsWithDuplicatedSiblingItems but for inlined data

related_scripts:
  - ReplacementNameForHistoryItemsWithDuplicatedForeignData
  - ReplacementNameForHistoryItemsWithDuplicatedSiblingItems
