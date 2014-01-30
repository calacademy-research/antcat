class AddTypeSpecimenUrl < ActiveRecord::Migration
  def up
    add_column :taxa, :type_specimen_url, :text
  end

  def down
    remove_column :taxa, :type_specimen_url
  end
end
