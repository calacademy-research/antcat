class AddTypeTaxonName < ActiveRecord::Migration
  def up
    add_column :taxa, :type_taxon_name, :text
  end

  def down
    remove_column :taxa, :type_taxon_name
  end
end
