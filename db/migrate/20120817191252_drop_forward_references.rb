class DropForwardReferences < ActiveRecord::Migration
  def change
    drop_table :forward_references
  end
end
