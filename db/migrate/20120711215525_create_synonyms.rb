class CreateSynonyms < ActiveRecord::Migration
  def change
    create_table :synonyms do |t|
      t.integer :senior_synonym_id
      t.integer :junior_synonym_id
      t.timestamps
    end
  end
end
