class AddHolTaxonData < ActiveRecord::Migration[4.2]
  def change
    create_table :hol_taxon_data do |t|
      t.integer :tnuid
      t.text :json
    end
  end
end
