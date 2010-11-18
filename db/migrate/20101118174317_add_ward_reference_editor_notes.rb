class AddWardReferenceEditorNotes < ActiveRecord::Migration
  def self.up
    add_column :ward_references, :editor_notes, :text
  end

  def self.down
    remove_column :ward_references, :editor_notes
  end
end
