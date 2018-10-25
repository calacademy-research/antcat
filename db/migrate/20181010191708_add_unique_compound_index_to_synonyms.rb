class AddUniqueCompoundIndexToSynonyms < ActiveRecord::Migration[5.1]
  def change
    remove_index :synonyms, [:junior_synonym_id, :senior_synonym_id]
    add_index :synonyms, [:junior_synonym_id, :senior_synonym_id], unique: true
  end
end
