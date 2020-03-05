class AddTnuidIndices < ActiveRecord::Migration[4.2]
  def change
    add_index "hol_taxon_data", ["tnuid"], name: "hol_taxon_data_tnuid_idx"
  end
end
