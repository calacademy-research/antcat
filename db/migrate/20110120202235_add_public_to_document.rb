class AddPublicToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :public, :boolean
  end

  def self.down
    remove_column :documents, :public
  end
end
