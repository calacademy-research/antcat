# frozen_string_literal: true

class RenameForeignKeys < ActiveRecord::Migration[6.1]
  def up
    add_foreign_key :history_items, :protonyms, name: :fk_history_items__protonym_id__protonyms__id
    add_foreign_key :taxa, :taxa, column: :current_taxon_id, name: :fk_taxa__current_taxon_id__taxa__id

    remove_foreign_key :history_items, name: :fk_taxon_history_items__protonym_id__protonyms__id
    remove_foreign_key :taxa, name: :fk_taxa__current_valid_taxon_id__taxa__id

    remove_foreign_key :site_notices, :users # Duplicated.
  end

  def down
    add_foreign_key :history_items, :protonyms, name: :fk_taxon_history_items__protonym_id__protonyms__id
    add_foreign_key :taxa, :taxa, column: :current_taxon_id, name: :fk_taxa__current_valid_taxon_id__taxa__id

    remove_foreign_key :history_items, name: :fk_history_items__protonym_id__protonyms__id
    remove_foreign_key :taxa, name: :fk_taxa__current_taxon_id__taxa__id

    add_foreign_key :site_notices, :users
  end
end
