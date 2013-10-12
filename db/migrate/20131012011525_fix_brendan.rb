class FixBrendan < ActiveRecord::Migration
  def up
    User.destroy_all "email = 'boudinotb@gmail.com'"
    User.create! email: 'boudinotb@gmail.com', name: 'Brendon E. Boudinot', can_edit_catalog: true, password: 'secret'
  end

  def down
  end
end
