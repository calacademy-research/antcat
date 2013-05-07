class RemoveEditingHistory < ActiveRecord::Migration
  def up
    drop_table :editing_history
  end

  def down
  end
end
