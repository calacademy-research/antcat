class TaxonInHolDetails < ActiveRecord::Migration[4.2]
  def change
    add_column :hol_taxon_data, :antcat_taxon_id, :integer
  end
end
