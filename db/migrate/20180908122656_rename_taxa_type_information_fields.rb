class RenameTaxaTypeInformationFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :taxa, :published_type_information, :primary_type_information
    rename_column :taxa, :additional_type_information, :secondary_type_information
  end
end
