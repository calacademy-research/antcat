class AddForwardRefType < ActiveRecord::Migration
  def up
    add_column :forward_refs, :type, :string
  end

  def down
    remove_column :forward_refs, :type
  end
end
