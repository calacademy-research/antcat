class CollectiveGroupNameAttribute < ActiveRecord::Migration
  def up
    add_column :taxa, :collective_group_name, :boolean
    Taxon.where(status: 'collective group name').update_all collective_group_name: true, status: 'valid'
  end

  def down
    Taxon.where(collective_group_name: true).update_all status: 'collective group name'
    remove_column :taxa, :collective_group_name
  end

end
