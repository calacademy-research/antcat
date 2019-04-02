class AddTypeFieldsToTaxa < ActiveRecord::Migration
  def change
    add_column :taxa, :published_type_information, :text, nil: true
    add_column :taxa, :additional_type_information, :text, nil: true
    add_column :taxa, :type_notes, :text, nil: true
  end
end
