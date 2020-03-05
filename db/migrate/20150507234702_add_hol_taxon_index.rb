class AddHolTaxonIndex < ActiveRecord::Migration[4.2]
  def change
    # These support the delete case, where we nil these out when we delete the objects
    add_index "hol_taxon_data", ["antcat_taxon_id"], name: "hol_taxon_data_antcat_taxon_id_idx"
    add_index "hol_taxon_data", ["antcat_name_id"], name: "hol_taxon_data_antcat_name_id_idx"
  end
end
