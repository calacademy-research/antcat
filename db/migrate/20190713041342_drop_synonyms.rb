class DropSynonyms < ActiveRecord::Migration[5.2]
  def up
    drop_table :synonyms
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
