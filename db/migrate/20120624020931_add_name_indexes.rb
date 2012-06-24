class AddNameIndexes < ActiveRecord::Migration
  def up
    add_index :taxa, :homonym_replaced_by_id
    add_index :taxa, :protonym_id
    add_index :taxa, :subgenus_id
    add_index :taxa, :type_name_id

    add_index :taxonomic_history_items, :taxon_id

    add_index :names, [:name, :type]
  end

  def down
    remove_index :names, :column => [:name, :type]

    remove_index :taxonomic_history_items, :column => :taxon_id

    remove_index :taxa, :column => :type_name_id
    remove_index :taxa, :column => :subgenus_id
    remove_index :taxa, :column => :protonym_id
    remove_index :taxa, :column => :homonym_replaced_by_id
  end
end
