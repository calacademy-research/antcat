class AddAttributesToTaxon < ActiveRecord::Migration
  def self.up
    add_column :taxa, :fossil, :boolean
    add_column :taxa, :taxonomic_history, :text
  end

  def self.down
    remove_column :taxa, :taxonomic_history
    remove_column :taxa, :fossil
  end
end
