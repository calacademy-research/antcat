class AddZach < ActiveRecord::Migration
  def up

    email = 'zelieberman@gmail.com'
    name = 'Zachary Lieberman'
    password = 'secret'

    User.destroy_all email: email
    User.create! email: email, name: name, password: password, can_edit_catalog: true

  end

end
