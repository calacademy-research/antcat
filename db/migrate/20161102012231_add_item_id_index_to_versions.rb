class AddItemIdIndexToVersions < ActiveRecord::Migration[4.2]
  def change
    add_index :versions, :item_id
  end
end
