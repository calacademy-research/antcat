class AddAuthorsRole < ActiveRecord::Migration
  def self.up
    add_column :references, :authors_role, :string
  end

  def self.down
    remove_column :references, :authors_role
  end
end
