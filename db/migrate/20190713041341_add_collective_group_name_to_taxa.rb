class AddCollectiveGroupNameToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa, :collective_group_name, :boolean, null: false, default: false
  end
end
