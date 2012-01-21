class AddTaxaHeadlineNotesTaxt < ActiveRecord::Migration
  def up
    add_column :taxa, :headline_notes_taxt, :text
  end

  def down
    remove_column :taxa, :headline_notes_taxt
  end
end
