class AddNestedReferenceId < ActiveRecord::Migration
  def self.up
    add_column :references, :nested_reference_id, :integer
    add_column :references, :pages_in, :string
  end

  def self.down
    remove_column :references, :nested_reference_id
    remove_column :references, :pages_in
  end
end
