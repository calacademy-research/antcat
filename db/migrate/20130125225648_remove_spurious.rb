class RemoveSpurious < ActiveRecord::Migration
  def up
    remove_column :names, :spurious
  end

  def down
    add_column :names, :spurious, :boolean
  end
end
