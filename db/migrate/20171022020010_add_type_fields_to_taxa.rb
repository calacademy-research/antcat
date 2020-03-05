class AddTypeFieldsToTaxa < ActiveRecord::Migration[4.2]
  def change
    add_column :taxa, :published_type_information, :text, nil: true
    add_column :taxa, :additional_type_information, :text, nil: true
    add_column :taxa, :type_notes, :text, nil: true
  end
end
