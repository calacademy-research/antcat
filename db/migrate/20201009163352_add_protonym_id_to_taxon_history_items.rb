# frozen_string_literal: true

class AddProtonymIdToTaxonHistoryItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :taxon_history_items, :protonym, type: :integer,
      index: { name: "ix_taxon_history_items__protonym_id" },
      foreign_key: { name: "fk_taxon_history_items__protonym_id__protonyms__id" }

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE taxon_history_items
            INNER JOIN taxa ON taxa.id = taxon_history_items.taxon_id
            SET taxon_history_items.protonym_id = taxa.protonym_id
        SQL
      end
    end
  end
end
