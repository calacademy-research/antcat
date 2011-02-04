class AddSubtaxaToTaxon < ActiveRecord::Migration
  def self.up
    remove_column :taxa, :parent_id

    add_column :taxa, :subfamily_id, :integer
    add_index :taxa, :subfamily_id, :name => 'taxa_subfamily_id_idx'

    add_column :taxa, :tribe_id, :integer
    add_index :taxa, :tribe_id, :name => 'taxa_tribe_id_idx'

    add_column :taxa, :genus_id, :integer
    add_index :taxa, :genus_id, :name => 'taxa_genus_id_idx'
  end

  def self.down
    remove_column :taxa, :genus_id
    remove_column :taxa, :tribe_id
    remove_column :taxa, :subfamily_id

    add_column :taxa, :parent_id, :integer
  end
end
