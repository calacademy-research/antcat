class AddBiogeographicRegion < ActiveRecord::Migration
  def up
    add_column :taxa, :biogeographic_region, :string
  end

  def down
    remove_column :taxa, :biogeographic_region
  end
end
