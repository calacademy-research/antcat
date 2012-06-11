class RemoveTypeTaxonXxx < ActiveRecord::Migration
  def up
    remove_column :taxa, :type_taxon_name
    remove_column :taxa, :type_taxon_rank
    rename_column :taxa, :type_taxon_taxt, :type_taxt
  end

  def down
    rename_column :taxa, :type_taxt, :type_taxon_taxt
    add_column :taxa, :type_taxon_rank, :string
    add_column :taxa, :type_taxon_name, :string
  end
end
