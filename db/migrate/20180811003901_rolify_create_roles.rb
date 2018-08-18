class RolifyCreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :resource, polymorphic: true
      t.timestamps
    end

    create_table :users_roles, id: false do |t|
      t.references :user
      t.references :role
    end

    add_index :roles, :name
    add_index :roles, [ :name, :resource_type, :resource_id ]
    add_index :users_roles, [:user_id, :role_id]

    # Be lazy and migrate data here.
    User.where(can_edit: true).each { |user| user.add_role :editor }
    User.where(is_superadmin: true).each { |user| user.add_role :superadmin }
  end
end
