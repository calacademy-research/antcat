class AddSubgenusId < ActiveRecord::Migration
  def up
    add_column :taxa, :subgenus_id, :integer
  end

  def down
    remove_column :taxa, :subgenus_id
  end
end
