class DropRolesAndUsersRoles < ActiveRecord::Migration[5.2]
  def up
    drop_table :roles
    drop_table :users_roles
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
