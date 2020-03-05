class AddValidToHol < ActiveRecord::Migration[4.2]
  def change
    add_column :hol_taxon_data, :valid_tnuid, :integer
    add_column :hol_taxon_data, :name, :string
    add_column :hol_taxon_data, :is_valid, :string
  end
end
