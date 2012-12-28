class AddNameIndex < ActiveRecord::Migration
  def up
    add_index :names, :name, name: 'name_name_index'
  end

  def down
    remove_index :names, name: 'name_name_index'
  end
end
