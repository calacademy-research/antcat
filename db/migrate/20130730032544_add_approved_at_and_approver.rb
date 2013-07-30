class AddApprovedAtAndApprover < ActiveRecord::Migration
  def up
    add_column :changes, :approver_id, :integer
    add_column :changes, :approved_at, :datetime
  end

  def down
    remove_column :changes, :approved_at
    remove_column :changes, :approver_id
  end
end
