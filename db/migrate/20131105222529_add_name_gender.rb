class AddNameGender < ActiveRecord::Migration
  def up
    add_column :names, :gender, :string
  end

  def down
    remove_column :names, :gender
  end
end
