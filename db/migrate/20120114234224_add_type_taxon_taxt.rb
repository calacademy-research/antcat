class AddTypeTaxonTaxt < ActiveRecord::Migration
  def up
    add_column :taxa, :type_taxon_taxt, :text
  end

  def down
    remove_column :taxa, :type_taxon_taxt
  end
end
