class AddHong < ActiveRecord::Migration
  def up
    add_column :taxa, :hong, :boolean
  end

  def down
    remove_column :taxa, :hong
  end
end
