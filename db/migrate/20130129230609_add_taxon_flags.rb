class AddTaxonFlags < ActiveRecord::Migration
  def up
    add_column :taxa, :unidentifiable, :boolean
    add_column :taxa, :unresolved_homonym, :boolean
  end

  def down
    remove_column :taxa, :unresolved_homonym
    remove_column :taxa, :unidentifiable
  end
end
