class RemoveCanApproveChanges < ActiveRecord::Migration
  def up
    remove_column :users, :can_approve_changes
  end

  def down
    add_column :users, :can_approve_changes, :boolean
  end
end
