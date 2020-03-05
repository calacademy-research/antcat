class RenameTypeSpecimenReference < ActiveRecord::Migration[4.2]
  def up
    rename_column :taxa, :type_specimen_reference, :type_specimen_repository rescue nil
  end

  def down
    rename_column :taxa, :type_specimen_repository, :type_specimen_reference rescue nil
  end
end
