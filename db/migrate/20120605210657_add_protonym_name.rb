class AddProtonymName < ActiveRecord::Migration
  def up
    add_column :protonyms, :name_id, :integer
    add_index :protonyms, :name_id, name: :protonyms_name_id_idx
  end

  def down
    remove_index :protonyms, :column => :name_id
    remove_column :protonyms, :name_id
  end
end
