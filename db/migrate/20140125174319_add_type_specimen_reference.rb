class AddTypeSpecimenReference < ActiveRecord::Migration
  def up
    add_column :taxa, :type_specimen_repository, :text
  end

  def down
    remove_column :taxa, :type_specimen_repository
  end
end
