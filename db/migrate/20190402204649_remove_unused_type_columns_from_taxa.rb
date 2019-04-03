class RemoveUnusedTypeColumnsFromTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :type_name_id, :integer
    remove_column :taxa, :type_fossil, :boolean
    remove_column :taxa, :verbatim_type_locality, :text
    remove_column :taxa, :type_specimen_repository, :text
    remove_column :taxa, :type_specimen_code, :text
    remove_column :taxa, :type_specimen_url, :text
  end
end
