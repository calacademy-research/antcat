class AddCurrentValidTaxonId < ActiveRecord::Migration
  def up
    add_column :taxa, :current_valid_taxon_id, :integer
  end

  def down
    remove_column :taxa, :current_valid_taxon_id
  end
end
