class RenamePrivateNotesToEditorNotes < ActiveRecord::Migration
  def self.up
    rename_column :refs, :private_notes, :editor_notes
  end

  def self.down
    rename_column :refs, :editor_notes, :private_notes
  end
end
