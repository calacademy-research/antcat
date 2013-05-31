class CollectiveGroupNameStatus < ActiveRecord::Migration
  def up
    Taxon.where(collective_group_name: true).update_all status: 'collective group name'
    remove_column :taxa, :collective_group_name
  end

  def down
    add_column :taxa, :collective_group_name, :boolean
    Taxon.where(status: 'collective group name').update_all collectve_group_name: true, status: 'valid'
  end
end
