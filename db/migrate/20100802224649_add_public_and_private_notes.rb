class AddPublicAndPrivateNotes < ActiveRecord::Migration
  def self.up
    rename_column :refs, :notes, :public_notes
    add_column :refs, :private_notes, :string
  end

  def self.down
    remove_column :refs, :private_notes
    rename_column :refs, :public_notes, :notes
  end
end
