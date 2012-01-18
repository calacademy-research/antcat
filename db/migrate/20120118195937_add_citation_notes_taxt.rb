class AddCitationNotesTaxt < ActiveRecord::Migration
  def up
    add_column :citations, :notes_taxt, :text
  end

  def down
    remove_column :citations, :notes_taxt
  end
end
