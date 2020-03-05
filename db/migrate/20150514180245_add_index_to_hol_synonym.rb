class AddIndexToHolSynonym < ActiveRecord::Migration[4.2]
  def change
    add_index "hol_synonyms", ["synonym_id"], name: "hol_synonyms_antcat_synonym_id_idx"
    add_index "hol_synonyms", ["tnuid"], name: "hol_synonyms_antcat_tnuid_idx"
  end
end
