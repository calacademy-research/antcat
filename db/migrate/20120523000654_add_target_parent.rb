class AddTargetParent < ActiveRecord::Migration
  def up
    add_column :forward_references, :target_parent, :integer
  end

  def down
    remove_column :forward_references, :target_parent
  end
end
