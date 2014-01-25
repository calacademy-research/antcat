class AddTypeSpecimenReference < ActiveRecord::Migration
  def up
    add_column :taxa, :type_specimen_reference, :text
  end

  def down
    remove_column :taxa, :type_specimen_reference
  end
end
