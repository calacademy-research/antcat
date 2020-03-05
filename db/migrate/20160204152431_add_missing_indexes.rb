class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :taxa, :current_valid_taxon_id
    add_index :references, [:id, :type]
    add_index :names, [:id, :type]
    add_index :synonyms, :junior_synonym_id
    add_index :synonyms, :senior_synonym_id
    add_index :synonyms, [:junior_synonym_id, :senior_synonym_id]
    add_index :changes, :user_changed_taxon_id
  end
end
