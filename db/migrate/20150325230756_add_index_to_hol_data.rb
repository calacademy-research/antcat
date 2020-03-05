class AddIndexToHolData < ActiveRecord::Migration[4.2]
  def change
    add_index "hol_data", ["taxon_id"], name: "hol_data_taxon_id_idx"
    add_index "hol_data", ["tnuid"], name: "hol_data_tnuid_idx"
  end
end
