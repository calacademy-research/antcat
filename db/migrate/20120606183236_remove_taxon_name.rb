class RemoveTaxonName < ActiveRecord::Migration
  def up
    remove_column :taxa, :name
  end

  def down
    add_column :taxa, :name, :string
  end
end
