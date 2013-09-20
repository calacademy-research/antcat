class AddFamilyToTaxa < ActiveRecord::Migration
  def change
    add_column :taxa, :family_id, :integer
    add_index :taxa, :family_id
  end
end
