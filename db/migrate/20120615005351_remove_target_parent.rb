class RemoveTargetParent < ActiveRecord::Migration
  def up
    remove_column :forward_references, :target_parent
  end

  def down
  end
end
