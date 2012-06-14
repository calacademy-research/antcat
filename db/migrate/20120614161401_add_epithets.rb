class AddEpithets < ActiveRecord::Migration
  def up
    add_column :names, :epithets, :string
    add_column :names, :html_epithets, :string
  end

  def down
    remove_column :names, :html_epithets
    remove_column :names, :epithets
  end
end
