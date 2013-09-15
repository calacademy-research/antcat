class FixUsersAgain < ActiveRecord::Migration
  def up
    add_column :users, :invitation_created_at, :datetime rescue nil
  end

  def down
    remove_column :users, :invitation_created_at
  end
end
