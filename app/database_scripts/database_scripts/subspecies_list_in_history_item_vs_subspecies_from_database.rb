module DatabaseScripts
  class SubspeciesListInHistoryItemVsSubspeciesFromDatabase < DatabaseScript
    def with_history_item_but_not_in_database
      Taxon.where(id: species_with_subspecies_history_items - valid_species_with_valid_subspecies)
    end

    def in_database_but_no_history_item
      Taxon.where(id: valid_species_with_valid_subspecies - species_with_subspecies_history_items)
    end

    def statistics
      <<~HTML.html_safe
        List #1 results: #{with_history_item_but_not_in_database.count}<br>
        List #2 results: #{in_database_but_no_history_item.count}
      HTML
    end

    def render
      as_table do |t|
        t.caption "List #1: Subspecies list in history items, but no subspecies from database (valid species with valid subspecies)"
        t.header 'Genus', 'Status'

        t.rows(with_history_item_but_not_in_database) do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status
          ]
        end
      end <<
        as_table do |t|
          t.caption "List #2: Subspecies from database (valid species with valid subspecies), but no subspecies list in history items"
          t.header 'Genus', 'Status'

          t.rows(in_database_but_no_history_item) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status
            ]
          end
        end
    end

    private

      def valid_species_with_valid_subspecies
        @valid_species_with_valid_subspecies ||= Species.valid.joins(:subspecies).where(subspecies_taxa: { status: Status::VALID }).distinct.pluck(:id)
      end

      def species_with_subspecies_history_items
        @species_with_subspecies_history_items ||= begin
          subspecies_history_items = TaxonHistoryItem.where('taxt LIKE ?', "%Current subspecies%")
          Taxon.where(id: subspecies_history_items.select(:taxon_id)).distinct.pluck(:id)
        end
      end
  end
end

__END__

category: Taxt2
tags: []

description: >
  **List #1** contains species we want to fix.


  Species in **List #2** will disappear from this script if a subspecies list is added to its history section.
  Since the plan is to get rid of this type of history items, these species can be ignored as long as subspecies
  in the "Current subspecies (nominal plus)" in the catalog is up to date.


  Issue: %github780

related_scripts:
  - SubspeciesHistoryItemsToDeleteByScript
  - SubspeciesListInHistoryItem
  - SubspeciesListInHistoryItemVsSubspeciesFromDatabase
