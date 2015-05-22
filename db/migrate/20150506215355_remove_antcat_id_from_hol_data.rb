class RemoveAntcatIdFromHolData < ActiveRecord::Migration
  def change
    remove_column :hol_data, :taxon_id
    remove_column :hol_data, :taxon
  end
end
