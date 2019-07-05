class DropSynonyms < ActiveRecord::Migration[5.2]
  def up
    drop_table :synonyms
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
