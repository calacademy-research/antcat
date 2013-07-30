class AddCanApproveChanges < ActiveRecord::Migration
  def up
    add_column :users, :can_approve_changes, :boolean
  end

  def down
    remove_column :users, :can_approve_changes
  end
end
