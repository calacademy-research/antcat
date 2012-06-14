class AddNameHtml < ActiveRecord::Migration
  def up
    add_column :names, :html_name, :string
    add_column :names, :html_epithet, :string
  end

  def down
    remove_column :names, :html_epithet
    remove_column :names, :html_name
  end
end
