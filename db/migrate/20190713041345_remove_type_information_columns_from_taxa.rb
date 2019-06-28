# Moved to `protonyms` in `MoveTypeFieldsToProtonym`.

class RemoveTypeInformationColumnsFromTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :primary_type_information, :text
    remove_column :taxa, :secondary_type_information, :text
    remove_column :taxa, :type_notes, :text
  end
end
