class RenameTextToTaxt < ActiveRecord::Migration
  def up
    rename_column :taxonomic_history_items, :text, :taxt
  end

  def down
    rename_column :taxonomic_history_items, :taxt, :text
  end
end
