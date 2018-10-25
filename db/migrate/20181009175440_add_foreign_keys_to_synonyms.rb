# Run this first: https://github.com/calacademy-research/antcat/issues/465

class AddForeignKeysToSynonyms < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :synonyms, :taxa, column: :junior_synonym_id, name: :fk_synonyms__junior_synonym_id__taxa__id
    add_foreign_key :synonyms, :taxa, column: :senior_synonym_id, name: :fk_synonyms__senior_synonym_id__taxa__id
    change_column_null :synonyms, :junior_synonym_id, false
    change_column_null :synonyms, :senior_synonym_id, false
  end
end
