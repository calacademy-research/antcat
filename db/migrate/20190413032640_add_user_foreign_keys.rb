class AddUserForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :issues,        :users, column: :adder_id,  name: :fk_issues__adder_id__users__id
    add_foreign_key :issues,        :users, column: :closer_id, name: :fk_issues__closer_id__users__id
    add_foreign_key :site_notices,  :users, column: :user_id,   name: :fk_site_notices__user_id__users__id
  end
end
