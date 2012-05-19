class AddForms < ActiveRecord::Migration
  def up
    add_column :citations, :forms, :string
  end

  def down
    remove_column :citations, :forms
  end
end
