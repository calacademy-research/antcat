class AddIndexesToVersions < ActiveRecord::Migration[4.2]
  def change
    add_index :versions, :change_id
    add_index :versions, :whodunnit
    add_index :versions, :event
  end
end
