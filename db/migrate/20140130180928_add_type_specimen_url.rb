class AddTypeSpecimenUrl < ActiveRecord::Migration[4.2]
  def up
    add_column :taxa, :type_specimen_url, :text
  end

  def down
    remove_column :taxa, :type_specimen_url
  end
end
