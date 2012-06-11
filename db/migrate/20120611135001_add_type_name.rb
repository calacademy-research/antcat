class AddTypeName < ActiveRecord::Migration
  def up
    add_column :taxa, :type_name_id, :integer
  end

  def down
    remove_column :taxa, :type_name_id
  end
end
