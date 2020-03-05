class HolSynonyms < ActiveRecord::Migration[4.2]
  def change
    create_table :hol_synonyms do |t|
      t.integer :tnuid
      t.integer :synonym_id
      t.text :json, size: 4294967295, limit: 4294967295
    end
  end
end
