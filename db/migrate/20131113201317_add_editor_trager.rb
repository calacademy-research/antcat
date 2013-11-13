class AddEditorTrager < ActiveRecord::Migration
  def up

    email = 'James.Trager@mobot.org'
    name = 'James Trager'
    password = 'secret'

    User.destroy_all email: email
    User.create! email: email, name: name, password: password, can_edit_catalog: true

  end
end
