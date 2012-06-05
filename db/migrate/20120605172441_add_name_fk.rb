class AddNameFk < ActiveRecord::Migration
  def up
    add_column :taxa, :name_id, :integer
    add_index :taxa, :name_id, name: :taxa_name_id_idx
  end

  def down
    remove_index :taxa, name: :taxa_name_id_idx
    remove_column :taxa, :name_id
  end
end
