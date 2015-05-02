class AddValidToHol < ActiveRecord::Migration
  def change

    add_column :hol_taxon_data, :valid_tnuid, :integer
    add_column :hol_taxon_data, :name, :string
    add_column :hol_taxon_data, :is_valid, :string


  end
end
