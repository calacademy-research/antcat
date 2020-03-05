class RemoveAntcatIdFromHolData < ActiveRecord::Migration[4.2]
  def change
    remove_column :hol_data, :taxon_id
    remove_column :hol_data, :taxon
  end
end
