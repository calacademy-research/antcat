class AddTypeSpecimenCode < ActiveRecord::Migration[4.2]
  def up
    add_column :taxa, :type_specimen_code, :text
  end

  def down
    remove_column :taxa, :type_specimen_code
  end
end
