class AddNameToForwardReference < ActiveRecord::Migration
  def change
    add_column :forward_refs, :name_id, :integer
  end
end
