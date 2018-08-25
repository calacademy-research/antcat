class RemoveCollisionMergeIdFromTaxa < ActiveRecord::Migration[5.1]
  def change
    remove_column :taxa, :collision_merge_id, :integer
  end
end
