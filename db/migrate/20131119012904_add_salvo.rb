class AddSalvo < ActiveRecord::Migration
  def up

    email = 'SOSSAJEF@si.edu'
    name = 'Jeffery Sosa-Calvo' 
    password = 'secret'

    User.destroy_all email: email
    User.create! email: email, name: name, password: password, can_edit_catalog: true

  end

end
