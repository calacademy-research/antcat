class FixUsersInvitation < ActiveRecord::Migration
  def up
    add_column :users, :invitation_accepted_at, :datetime rescue nil
  end

  def down
    remove_column :users, :invitation_accepted_at
  end
end
