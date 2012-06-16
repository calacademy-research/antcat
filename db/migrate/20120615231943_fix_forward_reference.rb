class FixForwardReference < ActiveRecord::Migration
  def up
    add_column :forward_references, :name_id, :integer
    add_column :forward_references, :fixee_id, :integer
    add_column :forward_references, :fixee_attribute, :string
    remove_column :forward_references, :source_id
    remove_column :forward_references, :target_name
    remove_column :forward_references, :fossil
  end

  def down
    add_column :forward_references, :fossil, :boolean
    add_column :forward_references, :target_name, :string
    add_column :forward_references, :source_id, :integer
    remove_column :forward_references, :fixee_attribute
    remove_column :forward_references, :fixee_id
    remove_column :forward_references, :name_id
  end
end
