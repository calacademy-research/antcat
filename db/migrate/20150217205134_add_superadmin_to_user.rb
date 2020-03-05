class AddSuperadminToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_superadmin, :boolean
    execute "update users set is_superadmin=0"
  end
end
