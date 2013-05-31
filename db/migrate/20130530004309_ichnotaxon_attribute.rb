class IchnotaxonAttribute < ActiveRecord::Migration
  def up
    add_column :taxa, :ichnotaxon, :boolean
    Taxon.update_all 'status = "ichnotaxon"', 'ichnotaxon = "1"'
  end

  def down
    Taxon.update_all 'ichnotaxon = "1"', 'status = "ichnotaxon"'
    remove_column :taxa, :ichnotaxon
  end
end
