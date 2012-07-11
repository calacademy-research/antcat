class CreateSynonyms < ActiveRecord::Migration
  def change
    create_table :synonyms do |t|
      t.integer :senior_id
      t.integer :junior_id
      t.timestamps
    end
  end
end
