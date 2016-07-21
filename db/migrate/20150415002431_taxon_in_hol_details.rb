class TaxonInHolDetails < ActiveRecord::Migration
  def change
    add_column :hol_taxon_data, :antcat_taxon_id, :integer
  end
end
